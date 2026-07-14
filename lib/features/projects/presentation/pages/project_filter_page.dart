import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_filter.dart';
import '../bloc/project_filter_bloc.dart';

enum _Field { none, manager, status, employee }

class ProjectFilterPage extends StatelessWidget {
  const ProjectFilterPage({required this.initial, super.key});

  final ProjectFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectFilterBloc>(
      create: (_) =>
          getIt<ProjectFilterBloc>()
            ..add(const ProjectFilterOptionsRequested()),
      child: _ProjectFilterView(initial: initial),
    );
  }
}

class _ProjectFilterView extends StatefulWidget {
  const _ProjectFilterView({required this.initial});

  final ProjectFilter initial;

  @override
  State<_ProjectFilterView> createState() => _ProjectFilterViewState();
}

class _ProjectFilterViewState extends State<_ProjectFilterView> {
  final _portalCtrl = OverlayPortalController();
  final _managerLink = LayerLink();
  final _statusLink = LayerLink();
  final _employeeLink = LayerLink();
  late final TextEditingController _titleController;

  _Field _open = _Field.none;
  int? _managerId;
  int? _employeeId;
  ProjectStatus? _status;
  DateTime? _createdFrom;
  TimeOfDay? _createdFromTime;
  DateTime? _createdTo;
  TimeOfDay? _createdToTime;
  DateTime? _deadlineFrom;
  TimeOfDay? _deadlineFromTime;
  DateTime? _deadlineTo;
  TimeOfDay? _deadlineToTime;

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
    final f = widget.initial;
    _titleController = TextEditingController(text: f.search);
    _managerId = f.managerId;
    _employeeId = f.employeeId?.toInt();
    _status = f.status;
    _createdFrom = f.createdFrom;
    _createdFromTime = _timeOf(f.createdFrom);
    _createdTo = f.createdTo;
    _createdToTime = _timeOf(f.createdTo);
    _deadlineFrom = f.deadlineFrom;
    _deadlineFromTime = _timeOf(f.deadlineFrom);
    _deadlineTo = f.deadlineTo;
    _deadlineToTime = _timeOf(f.deadlineTo);
  }

  @override
  void dispose() {
    _titleController.dispose();
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

  void _pick(VoidCallback assign) {
    setState(() {
      assign();
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  Future<void> _pickDate(_DateTarget target) async {
    final now = DateTime.now();
    final initial = switch (target) {
      _DateTarget.createdFrom => _createdFrom,
      _DateTarget.createdTo => _createdTo,
      _DateTarget.deadlineFrom => _deadlineFrom,
      _DateTarget.deadlineTo => _deadlineTo,
    };
    final picked = await showAppDatePicker(
      context,
      initialDate: initial ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      switch (target) {
        case _DateTarget.createdFrom:
          _createdFrom = picked;
        case _DateTarget.createdTo:
          _createdTo = picked;
        case _DateTarget.deadlineFrom:
          _deadlineFrom = picked;
        case _DateTarget.deadlineTo:
          _deadlineTo = picked;
      }
    });
  }

  Future<void> _pickTime(_DateTarget target) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          switch (target) {
            _DateTarget.createdFrom => _createdFromTime,
            _DateTarget.createdTo => _createdToTime,
            _DateTarget.deadlineFrom => _deadlineFromTime,
            _DateTarget.deadlineTo => _deadlineToTime,
          } ??
          const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked == null) return;
    setState(() {
      switch (target) {
        case _DateTarget.createdFrom:
          _createdFromTime = picked;
        case _DateTarget.createdTo:
          _createdToTime = picked;
        case _DateTarget.deadlineFrom:
          _deadlineFromTime = picked;
        case _DateTarget.deadlineTo:
          _deadlineToTime = picked;
      }
    });
  }

  void _reset() {
    setState(() {
      _titleController.clear();
      _managerId = null;
      _employeeId = null;
      _status = null;
      _createdFrom = null;
      _createdFromTime = null;
      _createdTo = null;
      _createdToTime = null;
      _deadlineFrom = null;
      _deadlineFromTime = null;
      _deadlineTo = null;
      _deadlineToTime = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    Navigator.of(context).pop(
      ProjectFilter(
        search: _titleController.text.trim(),
        managerId: _managerId,
        employeeId: _employeeId,
        status: _status,
        createdFrom: _combineStart(_createdFrom, _createdFromTime),
        createdTo: _combineEnd(_createdTo, _createdToTime),
        deadlineFrom: _combineStart(_deadlineFrom, _deadlineFromTime),
        deadlineTo: _combineEnd(_deadlineTo, _deadlineToTime),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: OverlayPortal(
          controller: _portalCtrl,
          overlayChildBuilder: _buildOverlay,
          child: BlocBuilder<ProjectFilterBloc, ProjectFilterState>(
            builder: (context, state) => Column(
              children: [
                AppFilterHeader(title: l10n.taskFilterTitle),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12.h,
                      children: [
                        AppFilterFieldBox(
                          label: l10n.projectFilterManager,
                          value: _userName(state, _managerId),
                          placeholder: l10n.projectFilterManagerHint,
                          link: _managerLink,
                          onTap: () => _toggle(_Field.manager),
                          onClear: () => setState(() => _managerId = null),
                        ),
                        AppFilterFieldBox(
                          label: l10n.taskFilterStatus,
                          value: _status == null
                              ? null
                              : _statusLabel(_status!, l10n),
                          placeholder: l10n.taskFilterStatusHint,
                          link: _statusLink,
                          onTap: () => _toggle(_Field.status),
                          onClear: () => setState(() => _status = null),
                        ),
                        _TextFilterField(
                          label: l10n.projectFilterTitleField,
                          placeholder: l10n.projectFilterTitleHint,
                          controller: _titleController,
                          onClear: () => setState(_titleController.clear),
                        ),
                        AppFilterFieldBox(
                          label: l10n.taskFilterEmployee,
                          value: _userName(state, _employeeId),
                          placeholder: l10n.taskFilterEmployeeHint,
                          link: _employeeLink,
                          onTap: () => _toggle(_Field.employee),
                          onClear: () => setState(() => _employeeId = null),
                        ),
                        _DateRange(
                          label: l10n.meetingFilterStartDateRange,
                          dateHint: l10n.taskFilterDateHint,
                          fromDate: _fmtDate(_createdFrom),
                          fromTime: _fmtTime(_createdFromTime),
                          toDate: _fmtDate(_createdTo),
                          toTime: _fmtTime(_createdToTime),
                          onFromDate: () => _pickDate(_DateTarget.createdFrom),
                          onFromTime: () => _pickTime(_DateTarget.createdFrom),
                          onToDate: () => _pickDate(_DateTarget.createdTo),
                          onToTime: () => _pickTime(_DateTarget.createdTo),
                        ),
                        _DateRange(
                          label: l10n.taskFilterDeadlineRange,
                          dateHint: l10n.taskFilterDateHint,
                          fromDate: _fmtDate(_deadlineFrom),
                          fromTime: _fmtTime(_deadlineFromTime),
                          toDate: _fmtDate(_deadlineTo),
                          toTime: _fmtTime(_deadlineToTime),
                          onFromDate: () => _pickDate(_DateTarget.deadlineFrom),
                          onFromTime: () => _pickTime(_DateTarget.deadlineFrom),
                          onToDate: () => _pickDate(_DateTarget.deadlineTo),
                          onToTime: () => _pickTime(_DateTarget.deadlineTo),
                        ),
                      ],
                    ),
                  ),
                ),
                AppFilterActionBar(
                  resetLabel: l10n.taskFilterReset,
                  applyLabel: l10n.taskFilterApply,
                  onReset: _reset,
                  onApply: _apply,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final link = switch (_open) {
      _Field.manager => _managerLink,
      _Field.status => _statusLink,
      _Field.employee => _employeeLink,
      _Field.none => null,
    };
    if (link == null) return const SizedBox.shrink();
    final width = MediaQuery.sizeOf(context).width - 40.w;

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
          child: SizedBox(width: width, child: _dropdownContent()),
        ),
      ],
    );
  }

  Widget _dropdownContent() {
    final state = context.read<ProjectFilterBloc>().state;
    final l10n = AppLocalizations.of(context);

    return AppFilterDropdownBox(
      emptyText: l10n.statEmpty,
      children: switch (_open) {
        _Field.manager => [
          for (final user in state.users)
            AppFilterDropdownItem(
              height: 48,
              selected: user.id == _managerId,
              onTap: () => _pick(() => _managerId = user.id),
              child: _OptionText(user: user),
            ),
        ],
        _Field.employee => [
          for (final user in state.users)
            AppFilterDropdownItem(
              height: 48,
              selected: user.id == _employeeId,
              onTap: () => _pick(() => _employeeId = user.id),
              child: _OptionText(user: user),
            ),
        ],
        _Field.status => [
          for (final status in _statuses)
            AppFilterDropdownItem(
              verticalPadding: 6,
              selected: status == _status,
              onTap: () => _pick(() => _status = status),
              child: _LabelRow(_statusLabel(status, l10n)),
            ),
        ],
        _Field.none => const [],
      },
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

enum _DateTarget { createdFrom, createdTo, deadlineFrom, deadlineTo }

String? _userName(ProjectFilterState state, int? id) {
  if (id == null) return null;
  for (final user in state.users) {
    if (user.id == id) return user.username;
  }
  return null;
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

TimeOfDay? _timeOf(DateTime? date) =>
    date == null ? null : TimeOfDay.fromDateTime(date);

DateTime? _combineStart(DateTime? date, TimeOfDay? time) {
  if (date == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    time?.hour ?? 0,
    time?.minute ?? 0,
  );
}

DateTime? _combineEnd(DateTime? date, TimeOfDay? time) {
  if (date == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    time?.hour ?? 23,
    time?.minute ?? 59,
    time == null ? 59 : 0,
    time == null ? 999 : 0,
  );
}

class _TextFilterField extends StatelessWidget {
  const _TextFilterField({
    required this.label,
    required this.placeholder,
    required this.controller,
    required this.onClear,
  });

  final String label;
  final String placeholder;
  final TextEditingController controller;
  final VoidCallback onClear;

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
            padding: EdgeInsets.only(left: 12.w, right: 6.w),
            child: SizedBox(
              height: 44.h,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      textInputAction: TextInputAction.search,
                      style: style,
                      cursorColor: colors.accentSub,
                      decoration: InputDecoration.collapsed(
                        hintText: placeholder,
                        hintStyle: style.copyWith(color: colors.textSub),
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, _) => value.text.trim().isEmpty
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: onClear,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.all(4.w),
                              child: Assets.icons.icClose.svg(
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
            ),
          ),
        ),
      ],
    );
  }
}

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.label,
    required this.dateHint,
    required this.fromDate,
    required this.fromTime,
    required this.toDate,
    required this.toTime,
    required this.onFromDate,
    required this.onFromTime,
    required this.onToDate,
    required this.onToTime,
  });

  final String label;
  final String dateHint;
  final String fromDate;
  final String fromTime;
  final String toDate;
  final String toTime;
  final VoidCallback onFromDate;
  final VoidCallback onFromTime;
  final VoidCallback onToDate;
  final VoidCallback onToTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        _DateTimeRow(
          date: fromDate,
          time: fromTime,
          dateHint: dateHint,
          onDate: onFromDate,
          onTime: onFromTime,
        ),
        SizedBox(height: 6.h),
        _DateTimeRow(
          date: toDate,
          time: toTime,
          dateHint: dateHint,
          onDate: onToDate,
          onTime: onToTime,
        ),
      ],
    );
  }
}

class _DateTimeRow extends StatelessWidget {
  const _DateTimeRow({
    required this.date,
    required this.time,
    required this.dateHint,
    required this.onDate,
    required this.onTime,
  });

  final String date;
  final String time;
  final String dateHint;
  final VoidCallback onDate;
  final VoidCallback onTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppFilterPickerBox(
            value: date,
            placeholder: dateHint,
            icon: Assets.icons.icCalendar,
            onTap: onDate,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: AppFilterPickerBox(
            value: time,
            placeholder: '00:00',
            icon: Assets.icons.icTuilconTime,
            onTap: onTime,
          ),
        ),
      ],
    );
  }
}

class _OptionText extends StatelessWidget {
  const _OptionText({required this.user});

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
                  .w(500)
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
