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
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/meeting_form.dart';
import '../bloc/meeting_create_bloc.dart';

enum _Field { none, project }

class MeetingCreatePage extends StatelessWidget {
  const MeetingCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeetingCreateBloc>(
      create: (_) =>
          getIt<MeetingCreateBloc>()
            ..add(const MeetingCreateOptionsRequested()),
      child: const _MeetingCreateView(),
    );
  }
}

class _MeetingCreateView extends StatefulWidget {
  const _MeetingCreateView();

  @override
  State<_MeetingCreateView> createState() => _MeetingCreateViewState();
}

class _MeetingCreateViewState extends State<_MeetingCreateView> {
  final _nameCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _penaltyCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _portalCtrl = OverlayPortalController();
  final _projectLink = LayerLink();

  _Field _open = _Field.none;
  ProjectShort? _project;
  DateTime? _date;
  TimeOfDay? _time;
  bool _completed = false;
  final Set<int> _participantIds = {};

  @override
  void dispose() {
    _nameCtrl.dispose();
    _linkCtrl.dispose();
    _descCtrl.dispose();
    _penaltyCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  void _toggle(_Field field) {
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == field ? _Field.none : field);
    _open == _Field.none ? _portalCtrl.hide() : _portalCtrl.show();
  }

  void _close() {
    setState(() => _open = _Field.none);
    _portalCtrl.hide();
  }

  void _selectProject(ProjectShort project) {
    setState(() {
      _project = project;
      _participantIds.clear();
      _open = _Field.none;
    });
    _portalCtrl.hide();
    context.read<MeetingCreateBloc>().add(
      MeetingCreateProjectSelected(project.id),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showAppDatePicker(
      context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 0, minute: 0),
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _openParticipants(MeetingCreateState state) async {
    final l10n = AppLocalizations.of(context);
    if (_project == null) {
      AppToast.showError(context, title: l10n.taskCreateSelectProjectFirst);
      return;
    }
    if (state.membersLoading) return;
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: l10n.meetingCreateParticipantsTitle,
        items: [
          for (final member in state.members)
            MultiSelectItem(
              id: member.id,
              initial: member.username,
              title: member.username,
              subtitle: member.position,
            ),
        ],
        selected: _participantIds,
      ),
    );
    if (result is Set<int>) {
      setState(() {
        _participantIds
          ..clear()
          ..addAll(result);
      });
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final duration = int.tryParse(_durationCtrl.text.trim());
    if (_project == null ||
        _nameCtrl.text.trim().isEmpty ||
        _linkCtrl.text.trim().isEmpty ||
        _descCtrl.text.trim().isEmpty ||
        _date == null ||
        duration == null) {
      AppToast.showError(context, title: l10n.meetingCreateRequiredError);
      return;
    }

    final time = _time ?? const TimeOfDay(hour: 0, minute: 0);
    final date = _date!;
    final startTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    final penalty = _penaltyCtrl.text.trim();

    context.read<MeetingCreateBloc>().add(
      MeetingCreateSubmitted(
        form: MeetingForm(
          project: _project!.id,
          title: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          link: _linkCtrl.text.trim(),
          penaltyPercentage: penalty.isEmpty ? null : penalty,
          startTime: startTime,
          durationMinutes: duration,
          participants: _participantIds.toList(),
        ),
        closeAfterCreate: _completed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<MeetingCreateBloc, MeetingCreateState>(
      listenWhen: (p, c) => p.submitStatus != c.submitStatus,
      listener: (context, state) {
        switch (state.submitStatus) {
          case MeetingCreateSubmitStatus.success:
            AppToast.showSuccess(context, title: l10n.meetingCreateSuccess);
            Navigator.of(context).maybePop(true);
          case MeetingCreateSubmitStatus.failure:
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.submitFailure?.message,
            );
          case MeetingCreateSubmitStatus.idle:
          case MeetingCreateSubmitStatus.submitting:
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
                _Header(title: l10n.meetingAdd),
                Expanded(
                  child: BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                    builder: (context, state) => SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12.h,
                        children: [
                          AppFilterFieldBox(
                            label: l10n.taskCreateFieldProject,
                            value: _project?.title,
                            placeholder: l10n.taskCreateProjectHint,
                            link: _projectLink,
                            onTap: () => _toggle(_Field.project),
                            onClear: () => setState(() {
                              _project = null;
                              _participantIds.clear();
                            }),
                          ),
                          _InputField(
                            label: l10n.taskCreateFieldName,
                            hint: l10n.meetingCreateNameHint,
                            controller: _nameCtrl,
                          ),
                          _InputField(
                            label: l10n.taskCreateFieldPenalty,
                            hint: l10n.meetingCreatePenaltyHint,
                            controller: _penaltyCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_MaxValueFormatter(100)],
                          ),
                          _InputField(
                            label: l10n.meetingCreateLink,
                            hint: l10n.meetingCreateLinkHint,
                            controller: _linkCtrl,
                            keyboardType: TextInputType.url,
                          ),
                          _TextAreaField(
                            label: l10n.taskCreateFieldDescription,
                            hint: l10n.meetingCreateDescriptionHint,
                            controller: _descCtrl,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AppFilterPickerBox(
                                  value: _fmtDate(_date),
                                  placeholder: l10n.taskFilterDateHint,
                                  icon: Assets.icons.icCalendar,
                                  onTap: _pickDate,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: AppFilterPickerBox(
                                  value: _fmtTime(_time),
                                  placeholder: '00:00',
                                  icon: Assets.icons.icTuilconTime,
                                  onTap: _pickTime,
                                ),
                              ),
                            ],
                          ).withLabels(
                            context,
                            left: l10n.meetingCreateStartDate,
                            right: l10n.taskCreateFieldTime,
                          ),
                          _InputField(
                            label: l10n.meetingCreateDuration,
                            hint: l10n.meetingCreateDurationHint,
                            controller: _durationCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          _ParticipantsField(
                            selected: _selectedMembers(state.members),
                            loading: state.membersLoading,
                            onPick: () => _openParticipants(state),
                            onRemove: (id) =>
                                setState(() => _participantIds.remove(id)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
                  buildWhen: (p, c) => p.submitStatus != c.submitStatus,
                  builder: (context, state) => _SubmitBar(
                    completed: _completed,
                    loading:
                        state.submitStatus ==
                        MeetingCreateSubmitStatus.submitting,
                    onCompletedChanged: (value) =>
                        setState(() => _completed = value),
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

  List<ProjectMember> _selectedMembers(List<ProjectMember> members) => [
    for (final member in members)
      if (_participantIds.contains(member.id)) member,
  ];

  Widget _buildOverlay(BuildContext context) {
    if (_open == _Field.none) return const SizedBox.shrink();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _projectLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width - 40.w,
            child: BlocBuilder<MeetingCreateBloc, MeetingCreateState>(
              builder: (context, state) => AppFilterDropdownBox(
                emptyText: AppLocalizations.of(context).statEmpty,
                children: [
                  for (final project in state.projects)
                    AppFilterDropdownItem(
                      selected: project == _project,
                      verticalPadding: 6,
                      onTap: () => _selectProject(project),
                      child: _ProjectOption(project: project),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _themedPicker(BuildContext context, Widget child) {
    final colors = AppColors.of(context);
    final isDark = colors.backgroundBase.computeLuminance() < 0.5;
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.r),
    );

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
          shape: shape,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: colors.accentSub),
        ),
      ),
      child: child,
    );
  }
}

extension _LabelRow on Widget {
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
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icClose.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
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
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: colors.textStrong,
      height: 20 / 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.only(left: 16.w, right: 8.w),
            child: SizedBox(
              height: 44.h,
              child: Center(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  inputFormatters: inputFormatters,
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
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      color: colors.textStrong,
      height: 20 / 13,
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

class _ProjectOption extends StatelessWidget {
  const _ProjectOption({required this.project});

  final ProjectShort project;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              project.title
                  .s(13.sp)
                  .w(700)
                  .h(20 / 13)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (project.description.isNotEmpty)
                project.description
                    .s(11.sp)
                    .w(500)
                    .h(16 / 11)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        if (project.deadline != null) ...[
          SizedBox(width: 12.w),
          _fmtDate(
            project.deadline,
          ).s(11.sp).w(500).h(16 / 11).c(colors.iconSub),
        ],
      ],
    );
  }
}

class _ParticipantsField extends StatelessWidget {
  const _ParticipantsField({
    required this.selected,
    required this.loading,
    required this.onPick,
    required this.onRemove,
  });

  final List<ProjectMember> selected;
  final bool loading;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(l10n.meetingCreateParticipantsLabel),
        InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: appFilterFieldDecoration(colors),
            child: selected.isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      child: Column(
                        children: [
                          l10n.meetingCreateParticipantsHelp
                              .s(11.sp)
                              .w(500)
                              .h(16 / 11)
                              .c(colors.textSub)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          SizedBox(height: 8.h),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.backgroundElevation3,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: colors.strokeSub,
                                width: 1.w,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 6.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (loading)
                                    SizedBox(
                                      width: 12.w,
                                      height: 12.w,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5.w,
                                        color: colors.iconStrong,
                                      ),
                                    )
                                  else
                                    Assets.icons.icPlus.svg(
                                      width: 11.w,
                                      height: 16.w,
                                      colorFilter: ColorFilter.mode(
                                        colors.iconStrong,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  SizedBox(width: 2.w),
                                  l10n.meetingCreateParticipantsAdd
                                      .s(11.sp)
                                      .w(500)
                                      .h(16 / 11)
                                      .c(colors.textStrong),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.fromLTRB(10.w, 6.h, 8.w, 6.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: [
                          for (final member in selected)
                            _ParticipantChip(
                              member: member,
                              onRemove: () => onRemove(member.id),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _ParticipantChip extends StatelessWidget {
  const _ParticipantChip({required this.member, required this.onRemove});

  final ProjectMember member;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = member.position.isEmpty
        ? member.username
        : '${member.username} | ${member.position}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.w, right: 4.w, top: 4.h, bottom: 4.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 285.w),
              child: label
                  .s(13.sp)
                  .w(500)
                  .h(16 / 13)
                  .c(colors.iconSub)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 4.w),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(8.r),
              child: Assets.icons.icClose.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({
    required this.completed,
    required this.loading,
    required this.onCompletedChanged,
    required this.onSubmit,
  });

  final bool completed;
  final bool loading;
  final ValueChanged<bool> onCompletedChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.backgroundBase),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: l10n.meetingCreateCompleted
                        .s(15.sp)
                        .w(800)
                        .h(24 / 15)
                        .c(colors.textStrong),
                  ),
                  _SmallSwitch(
                    value: completed,
                    enabled: !loading,
                    onChanged: onCompletedChanged,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
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
                                l10n.meetingAdd
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

class _SmallSwitch extends StatelessWidget {
  const _SmallSwitch({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: enabled ? () => onChanged(!value) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 40.w,
        height: 21.h,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: value ? colors.accentStrong : colors.backgroundElevation3,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Align(
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.textWhite,
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 17.w, height: 17.w),
          ),
        ),
      ),
    );
  }
}

class _MaxValueFormatter extends TextInputFormatter {
  _MaxValueFormatter(this.max);

  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = int.tryParse(newValue.text);
    if (parsed == null || parsed > max) return oldValue;
    return newValue;
  }
}

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

String _fmtTime(TimeOfDay? t) {
  if (t == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(t.hour)}:${two(t.minute)}';
}
