import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_file_actions.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_document.dart';
import '../../domain/entities/project_form.dart';
import '../bloc/project_create_bloc.dart';

enum _Field { none, status, manager }

class AddProjectPage extends StatelessWidget {
  const AddProjectPage({
    super.key,
    this.project,
    this.readOnly = false,
    this.screenTitle,
  });

  final Project? project;
  final bool readOnly;
  final String? screenTitle;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectCreateBloc>(
      create: (_) {
        final bloc = getIt<ProjectCreateBloc>();
        if (!readOnly) bloc.add(const ProjectCreateOptionsRequested());
        if (project != null) bloc.add(ProjectDocumentsRequested(project!.id));
        return bloc;
      },
      child: _AddProjectView(
        project: project,
        readOnly: readOnly,
        screenTitle: screenTitle,
      ),
    );
  }
}

class _AddProjectView extends StatefulWidget {
  const _AddProjectView({
    required this.project,
    required this.readOnly,
    required this.screenTitle,
  });

  final Project? project;
  final bool readOnly;
  final String? screenTitle;

  @override
  State<_AddProjectView> createState() => _AddProjectViewState();
}

class _AddProjectViewState extends State<_AddProjectView> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _prefixCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  final _portalCtrl = OverlayPortalController();
  final _statusLink = LayerLink();
  final _managerLink = LayerLink();

  _Field _open = _Field.none;
  ProjectStatus? _status;
  UserShort? _manager;
  DateTime? _deadlineDate;
  TimeOfDay? _deadlineTime;
  bool _active = true;
  final Set<int> _employeeIds = {};
  final Set<int> _testerIds = {};

  /// Loyihaga biriktiriladigan yangi hujjatlar.
  final List<PlatformFile> _files = [];
  final Set<int> _removedDocumentIds = {};

  Project? get _project => widget.project;

  static const _statuses = [
    ProjectStatus.planning,
    ProjectStatus.active,
    ProjectStatus.overdue,
    ProjectStatus.completed,
    ProjectStatus.cancelled,
  ];

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    if (project == null) return;

    _nameCtrl.text = project.title;
    _descCtrl.text = project.description;
    _prefixCtrl.text = project.prefix;
    _priceCtrl.text = project.projectPrice;
    _penaltyCtrl.text = project.penaltyPercentage;
    _status = project.status == ProjectStatus.unknown ? null : project.status;
    _manager = project.manager == null
        ? null
        : UserShort(
            id: project.manager!.id,
            username: project.manager!.username,
            position: project.manager!.position,
            avatar: project.manager!.avatar,
          );
    _employeeIds.addAll(project.employees.map((user) => user.id));
    _testerIds.addAll(project.testers.map((user) => user.id));
    _deadlineDate = project.deadline;
    _deadlineTime = project.deadline == null
        ? null
        : TimeOfDay.fromDateTime(project.deadline!);
    _active = !project.isHidden;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _prefixCtrl.dispose();
    _penaltyCtrl.dispose();
    super.dispose();
  }

  void _toggle(_Field field) {
    if (widget.readOnly) return;
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == field ? _Field.none : field);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _pick(VoidCallback assign) {
    setState(() {
      assign();
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  Future<void> _pickDate() async {
    if (widget.readOnly) return;
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _deadlineDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _deadlineDate = picked;
        _deadlineTime ??= const TimeOfDay(hour: 23, minute: 59);
      });
    }
  }

  Future<void> _pickTime() async {
    if (widget.readOnly) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _deadlineTime ?? const TimeOfDay(hour: 23, minute: 59),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) setState(() => _deadlineTime = picked);
  }

  Future<void> _openUsers({
    required String title,
    required List<UserShort> users,
    required Set<int> selected,
  }) async {
    if (widget.readOnly) return;
    _close();
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: title,
        items: [
          for (final user in users)
            MultiSelectItem(
              id: user.id,
              initial: user.username,
              title: user.username,
              subtitle: user.position,
              avatarUrl: user.avatar,
            ),
        ],
        selected: selected,
      ),
    );
    if (result is Set<int>) {
      setState(() {
        selected
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _pickFiles() async {
    // Dizayn talabi: faqat doc/pdf/excel formatlari. Tanlagich platforma
    // xatolarini otishi mumkin — ilovani yiqitmaymiz.
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: const ['doc', 'docx', 'pdf', 'xls', 'xlsx'],
      );
      if (result == null) return;
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _files.add(f);
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).commonError,
      );
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    if (_nameCtrl.text.trim().isEmpty ||
        _prefixCtrl.text.trim().isEmpty ||
        _manager == null ||
        _deadlineDate == null) {
      AppToast.showError(context, title: l10n.projectCreateRequiredError);
      return;
    }

    final date = _deadlineDate!;
    final time = _deadlineTime ?? const TimeOfDay(hour: 23, minute: 59);
    final deadline = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    final price = _decimalText(_priceCtrl.text);
    final penalty = _decimalText(_penaltyCtrl.text);
    final form = ProjectForm(
      prefix: _prefixCtrl.text.trim(),
      title: _nameCtrl.text.trim(),
      description: _emptyToNull(_descCtrl.text),
      manager: _manager!.id,
      testers: _testerIds.toList(),
      employees: _employeeIds.toList(),
      deadline: deadline,
      projectPrice: price.isEmpty ? null : price,
      penaltyPercentage: penalty.isEmpty ? null : penalty,
      status: _status,
      isHidden: !_active,
    );
    context.read<ProjectCreateBloc>().add(
      _project == null
          ? ProjectCreateSubmitted(
              form,
              filePaths: [for (final f in _files) f.path!],
            )
          : ProjectUpdated(
              _project!.id,
              form,
              filePaths: [for (final f in _files) f.path!],
              removedDocumentIds: _removedDocumentIds.toList(),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProjectCreateBloc, ProjectCreateState>(
      listenWhen: (previous, current) =>
          previous.submitStatus != current.submitStatus,
      listener: (context, state) {
        switch (state.submitStatus) {
          case ProjectCreateSubmitStatus.success:
            if (state.documentsFailed) {
              AppToast.showError(
                context,
                title: _project == null
                    ? l10n.projectCreateDocsFailed
                    : l10n.projectUpdateDocsFailed,
              );
            } else {
              AppToast.showSuccess(
                context,
                title: _project == null
                    ? l10n.projectCreateSuccess
                    : l10n.projectUpdateSuccess,
              );
            }
            Navigator.of(context).maybePop(true);
          case ProjectCreateSubmitStatus.failure:
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.submitFailure?.message,
            );
          case ProjectCreateSubmitStatus.idle:
          case ProjectCreateSubmitStatus.submitting:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: OverlayPortal(
            controller: _portalCtrl,
            overlayChildBuilder: _buildOverlay,
            child: Column(
              children: [
                _Header(
                  title:
                      widget.screenTitle ??
                      (_project == null
                          ? l10n.projectAdd
                          : l10n.projectEditTitle),
                ),
                Expanded(
                  child: BlocBuilder<ProjectCreateBloc, ProjectCreateState>(
                    builder: (context, state) => SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12.h,
                        children: [
                          _InputField(
                            label: l10n.taskCreateFieldName,
                            hint: l10n.taskCreateNameHint,
                            controller: _nameCtrl,
                            readOnly: widget.readOnly,
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskFilterStatus,
                            value: _status == null
                                ? null
                                : _statusLabel(_status!, l10n),
                            placeholder: l10n.taskFilterStatusHint,
                            link: _statusLink,
                            onTap: widget.readOnly
                                ? _noop
                                : () => _toggle(_Field.status),
                            onClear: widget.readOnly
                                ? _noop
                                : () => setState(() => _status = null),
                            showClear: !widget.readOnly,
                          ),
                          _TextAreaField(
                            label: l10n.taskCreateFieldDescription,
                            hint: l10n.taskCreateDescriptionHint,
                            controller: _descCtrl,
                            readOnly: widget.readOnly,
                          ),
                          AppFilterFieldBox(
                            label: l10n.projectFilterManager,
                            value: _manager?.username,
                            placeholder: l10n.projectFilterManagerHint,
                            link: _managerLink,
                            onTap: widget.readOnly
                                ? _noop
                                : () => _toggle(_Field.manager),
                            onClear: widget.readOnly
                                ? _noop
                                : () => setState(() => _manager = null),
                            showClear: !widget.readOnly,
                          ),
                          _InputField(
                            label: l10n.projectCreateManagerBonus,
                            hint: l10n.projectCreateManagerBonusHint,
                            controller: _priceCtrl,
                            readOnly: widget.readOnly,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_DecimalInputFormatter()],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _InputField(
                                  label: l10n.projectFilterTitleField,
                                  hint: l10n.projectCreatePrefixHint,
                                  controller: _prefixCtrl,
                                  readOnly: widget.readOnly,
                                ),
                              ),
                              SizedBox(width: 20.w),
                              Expanded(
                                child: _InputField(
                                  label: l10n.taskCreateFieldPenalty,
                                  hint: l10n.taskCreatePenaltyHint,
                                  controller: _penaltyCtrl,
                                  readOnly: widget.readOnly,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [_MaxPercentFormatter()],
                                  suffix: '%',
                                ),
                              ),
                            ],
                          ),
                          _UserMultiField(
                            label: l10n.projectCreateEmployees,
                            placeholder: l10n.projectCreateEmployeesHint,
                            selected: widget.readOnly
                                ? _participantUsers(
                                    _project?.employees ?? const [],
                                  )
                                : _selectedUsers(state.users, _employeeIds),
                            loading: state.optionsLoading,
                            readOnly: widget.readOnly,
                            onPick: () => _openUsers(
                              title: l10n.projectCreateEmployees,
                              users: state.users,
                              selected: _employeeIds,
                            ),
                            onRemove: (id) =>
                                setState(() => _employeeIds.remove(id)),
                          ),
                          _UserMultiField(
                            label: l10n.projectCreateTesters,
                            placeholder: l10n.projectCreateTestersHint,
                            selected: widget.readOnly
                                ? _participantUsers(
                                    _project?.testers ?? const [],
                                  )
                                : _selectedUsers(state.users, _testerIds),
                            loading: state.optionsLoading,
                            readOnly: widget.readOnly,
                            onPick: () => _openUsers(
                              title: l10n.projectCreateTesters,
                              users: state.users,
                              selected: _testerIds,
                            ),
                            onRemove: (id) =>
                                setState(() => _testerIds.remove(id)),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AppFilterPickerBox(
                                  value: _fmtDate(_deadlineDate),
                                  placeholder: l10n.taskFilterDateHint,
                                  icon: Assets.icons.icCalendar,
                                  onTap: widget.readOnly ? _noop : _pickDate,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: AppFilterPickerBox(
                                  value: _fmtTime(_deadlineTime),
                                  placeholder: '00:00',
                                  icon: Assets.icons.icTuilconTime,
                                  onTap: widget.readOnly ? _noop : _pickTime,
                                ),
                              ),
                            ],
                          ).withLabels(
                            context,
                            left: l10n.taskCreateFieldDeadline,
                            right: l10n.taskCreateFieldTime,
                          ),
                          // Yaratish/tahrirlash/detail uchun umumiy fayl oqimi.
                          if (!widget.readOnly ||
                              state.documentsLoading ||
                              state.documents.isNotEmpty ||
                              _files.isNotEmpty)
                            _FilesSection(
                              label: widget.readOnly
                                  ? l10n.projectExistingFilesLabel
                                  : l10n.projectCreateFilesLabel,
                              files: _files,
                              existing: [
                                for (final document in state.documents)
                                  if (!_removedDocumentIds.contains(
                                    document.id,
                                  ))
                                    document,
                              ],
                              loading: state.documentsLoading,
                              readOnly: widget.readOnly,
                              onPick: _pickFiles,
                              onRemove: (f) => setState(() => _files.remove(f)),
                              onRemoveExisting: (document) => setState(
                                () => _removedDocumentIds.add(document.id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (!widget.readOnly)
                  BlocBuilder<ProjectCreateBloc, ProjectCreateState>(
                    buildWhen: (previous, current) =>
                        previous.submitStatus != current.submitStatus,
                    builder: (context, state) => _SubmitBar(
                      label: _project == null
                          ? l10n.projectAdd
                          : l10n.projectEditTitle,
                      active: _active,
                      loading:
                          state.submitStatus ==
                          ProjectCreateSubmitStatus.submitting,
                      onActiveChanged: (value) =>
                          setState(() => _active = value),
                      onSubmit: _submit,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<UserShort> _selectedUsers(List<UserShort> users, Set<int> ids) => [
    for (final user in users)
      if (ids.contains(user.id)) user,
  ];

  List<UserShort> _participantUsers(List<ProjectParticipant> users) => [
    for (final user in users)
      UserShort(
        id: user.id,
        username: user.username,
        position: user.position,
        avatar: user.avatar,
      ),
  ];

  Widget _buildOverlay(BuildContext context) {
    final link = switch (_open) {
      _Field.status => _statusLink,
      _Field.manager => _managerLink,
      _Field.none => null,
    };
    if (link == null) return const SizedBox.shrink();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 40.w,
            child: _dropdownContent(),
          ),
        ),
      ],
    );
  }

  Widget _dropdownContent() {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ProjectCreateBloc, ProjectCreateState>(
      builder: (context, state) => AppFilterDropdownBox(
        emptyText: l10n.statEmpty,
        children: switch (_open) {
          _Field.status => [
            for (final status in _statuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: status == _status,
                onTap: () => _pick(() => _status = status),
                child: _LabelRow(_statusLabel(status, l10n)),
              ),
          ],
          _Field.manager => [
            if (state.optionsLoading)
              const _DropdownLoader()
            else
              for (final user in state.managers)
                AppFilterDropdownItem(
                  height: 48,
                  selected: user == _manager,
                  onTap: () => _pick(() => _manager = user),
                  child: _UserOption(user: user),
                ),
          ],
          _Field.none => const [],
        },
      ),
    );
  }

  Widget _themedPicker(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    final isDark = colors.backgroundBase.computeLuminance() < 0.5;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: colors.accentSub,
          onPrimary: colors.textWhite,
          surface: colors.backgroundBase,
          onSurface: colors.textStrong,
        ),
        timePickerTheme: TimePickerThemeData(
          backgroundColor: colors.backgroundBase,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colors.accentSub),
        ),
      ),
      child: child,
    );
  }
}

extension _LabelPair on Widget {
  Widget withLabels(
    BuildContext context, {
    required String left,
    required String right,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: AppFilterFieldLabel(left)),
            SizedBox(width: 16.w),
            Expanded(child: AppFilterFieldLabel(right)),
          ],
        ),
        this,
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(width: 24.w),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .h(28 / 17)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Assets.icons.icClose.svg(
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.suffix,
    this.readOnly = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? suffix;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 12.w),
            child: SizedBox(
              height: 44.h,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      inputFormatters: inputFormatters,
                      readOnly: readOnly,
                      style: style,
                      cursorColor: colors.accentSub,
                      decoration: InputDecoration.collapsed(
                        hintText: hint,
                        hintStyle: style.copyWith(color: colors.textSub),
                      ),
                    ),
                  ),
                  if (suffix != null) ...[
                    SizedBox(width: 6.w),
                    suffix!.s(13.sp).w(500).c(colors.textStrong),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextAreaField extends StatelessWidget {
  const _TextAreaField({
    required this.label,
    required this.hint,
    required this.controller,
    this.readOnly = false,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 9.h),
            child: SizedBox(
              height: 60.h,
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: style,
                cursorColor: colors.accentSub,
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: style.copyWith(color: colors.textSub),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMultiField extends StatelessWidget {
  const _UserMultiField({
    required this.label,
    required this.placeholder,
    required this.selected,
    required this.loading,
    required this.onPick,
    required this.onRemove,
    this.readOnly = false,
  });

  final String label;
  final String placeholder;
  final List<UserShort> selected;
  final bool loading;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: readOnly || loading ? null : onPick,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: appFilterFieldDecoration(colors),
            child: selected.isEmpty
                ? SizedBox(
                    height: 44.h,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: placeholder
                                .s(13.sp)
                                .w(500)
                                .h(20 / 13)
                                .c(colors.textSub)
                                .copyWith(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                          if (loading)
                            SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: colors.accentSub,
                              ),
                            )
                          else
                            Assets.icons.icTuilconChervonDown.svg(
                              width: 16.w,
                              height: 16.w,
                              colorFilter: ColorFilter.mode(
                                colors.iconSub,
                                BlendMode.srcIn,
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 6.h, 8.w, 6.h),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxChipWidth = constraints.maxWidth.isFinite
                            ? constraints.maxWidth
                            : MediaQuery.sizeOf(context).width - 58.w;
                        return SizedBox(
                          width: double.infinity,
                          child: Wrap(
                            spacing: 4.w,
                            runSpacing: 4.h,
                            children: [
                              for (final user in selected)
                                _UserChip(
                                  user: user,
                                  maxWidth: maxChipWidth,
                                  showRemove: !readOnly,
                                  onRemove: () => onRemove(user.id),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _UserChip extends StatelessWidget {
  const _UserChip({
    required this.user,
    required this.maxWidth,
    required this.showRemove,
    required this.onRemove,
  });

  final UserShort user;
  final double maxWidth;
  final bool showRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = user.position.isEmpty
        ? user.username
        : '${user.username} | ${user.position}';

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 8.w,
            right: 4.w,
            top: 4.h,
            bottom: 4.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TuiAvatar(
                initial: user.username,
                avatarUrl: user.avatar,
                size: 20,
              ),
              SizedBox(width: 4.w),
              Flexible(
                child: label
                    .s(13.sp)
                    .w(500)
                    .h(16 / 13)
                    .c(colors.iconSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (showRemove) ...[
                SizedBox(width: 4.w),
                InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Assets.icons.icClose.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _UserOption extends StatelessWidget {
  const _UserOption({required this.user});

  final UserShort user;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        TuiAvatar(initial: user.username, avatarUrl: user.avatar, size: 32),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              user.username
                  .s(13.sp)
                  .w(700)
                  .h(20 / 13)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (user.position.isNotEmpty)
                user.position
                    .s(11.sp)
                    .w(500)
                    .h(16 / 11)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ],
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => text
      .s(13.sp)
      .w(700)
      .c(AppColors.of(context).textStrong)
      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);
}

class _DropdownLoader extends StatelessWidget {
  const _DropdownLoader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: SizedBox(
          width: 20.w,
          height: 20.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: AppColors.of(context).accentSub,
          ),
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.label,
    required this.active,
    required this.loading,
    required this.onActiveChanged,
    required this.onSubmit,
  });

  final String label;
  final bool active;
  final bool loading;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.backgroundBase),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row(
              //   children: [
              //     Expanded(
              //       child: l10n.projectCreateActive
              //           .s(15.sp)
              //           .w(800)
              //           .h(24 / 15)
              //           .c(colors.textStrong),
              //     ),
              //     _SmallSwitch(
              //       value: active,
              //       enabled: !loading,
              //       onChanged: onActiveChanged,
              //     ),
              //   ],
              // ),
              // SizedBox(height: 12.h),
              InkWell(
                onTap: loading ? null : onSubmit,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentStrong,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Center(
                      child: loading
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.w,
                                color: colors.textWhite,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.icTuilconCheck.svg(
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.textWhite,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                label
                                    .s(15.sp)
                                    .w(800)
                                    .h(24 / 15)
                                    .c(colors.textWhite),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Fayl qo'shish" bo'limi (dizayn 469:275292): ikkita shtrixli quti —
/// "Fayl yuklash" (accent) va "+" — pastida tanlangan fayl chiplari.
/// Vazifa qo'shish sahifasidagi naqsh bilan bir xil.
class _FilesSection extends StatelessWidget {
  const _FilesSection({
    required this.label,
    required this.files,
    required this.existing,
    required this.loading,
    required this.readOnly,
    required this.onPick,
    required this.onRemove,
    required this.onRemoveExisting,
  });

  final String label;
  final List<PlatformFile> files;
  final List<ProjectDocument> existing;
  final bool loading;
  final bool readOnly;
  final VoidCallback onPick;
  final ValueChanged<PlatformFile> onRemove;
  final ValueChanged<ProjectDocument> onRemoveExisting;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label.s(15.sp).w(800).c(colors.textStrong),
        SizedBox(height: 8.h),
        if (!readOnly)
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPick,
                  borderRadius: BorderRadius.circular(20.r),
                  child: _DashedBox(
                    color: colors.strokeAccent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Assets.icons.icDocument.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.textSoft,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        l10n.taskCreateFileUpload
                            .s(11.sp)
                            .w(700)
                            .c(colors.textSoft),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: InkWell(
                  onTap: onPick,
                  borderRadius: BorderRadius.circular(20.r),
                  child: _DashedBox(
                    color: colors.strokeStrong,
                    child: Assets.icons.icPlus.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        if (loading)
          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: Center(
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: colors.accentSub,
                ),
              ),
            ),
          ),
        if (existing.isNotEmpty || files.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              for (final document in existing)
                _FileChip(
                  name: document.fileName,
                  url: document.fileUrl,
                  onRemove: readOnly ? null : () => onRemoveExisting(document),
                ),
              for (final f in files)
                _FileChip(name: f.name, onRemove: () => onRemove(f)),
            ],
          ),
        ],
      ],
    );
  }
}

class _FileChip extends StatelessWidget {
  const _FileChip({required this.name, this.url = '', this.onRemove});

  final String name;
  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 132.w),
              child: name
                  .s(11.sp)
                  .w(700)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            if (url.isNotEmpty) ...[
              SizedBox(width: 4.w),
              AppFileActions(
                url: url,
                openLabel: AppLocalizations.of(context).commonOpenFile,
                downloadLabel: AppLocalizations.of(context).commonDownloadFile,
                errorTitle: AppLocalizations.of(context).commonError,
              ),
            ],
            if (onRemove != null) ...[
              SizedBox(width: 2.w),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8.r),
                child: Assets.icons.icClose.svg(
                  width: 14.w,
                  height: 14.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconSub,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedRRectPainter(color: color, radius: 20.r),
      child: SizedBox(
        height: 56.h,
        child: Center(child: child),
      ),
    );
  }
}

/// Shtrixli (dashed) yumaloq to'rtburchak chegara chizuvchi.
class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + dash), paint);
        dist += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) =>
      old.color != color || old.radius != radius;
}

class _DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty || RegExp(r'^\d{0,10}(\.\d{0,2})?$').hasMatch(text)) {
      return newValue;
    }
    return oldValue;
  }
}

class _MaxPercentFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d{0,3}(\.\d{0,2})?$').hasMatch(text)) return oldValue;
    final value = num.tryParse(text);
    if (value == null || value > 100) return oldValue;
    return newValue;
  }
}

String _statusLabel(ProjectStatus status, AppLocalizations l10n) =>
    switch (status) {
      ProjectStatus.planning => l10n.projectStatusPlanning,
      ProjectStatus.active => l10n.projectStatusActive,
      ProjectStatus.overdue => l10n.projectStatusOverdue,
      ProjectStatus.completed => l10n.projectStatusCompleted,
      ProjectStatus.cancelled => l10n.projectStatusCancelled,
      ProjectStatus.unknown => '',
    };

String _fmtDate(DateTime? date) {
  if (date == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year}';
}

String _fmtTime(TimeOfDay? time) {
  if (time == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(time.hour)}:${two(time.minute)}';
}

String _decimalText(String text) => text.trim().replaceAll(',', '.');

String? _emptyToNull(String text) {
  final value = text.trim();
  return value.isEmpty ? null : value;
}

void _noop() {}
