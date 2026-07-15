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
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/user_report_filter.dart';
import '../bloc/reports_filter_bloc.dart';

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field {
  none,
  position,
  region,
  projectStatus,
  taskStatus,
  meetingStatus,
  expenseStatus,
  payrollType,
}

/// Xodim bo'yicha hisobotni filtrlash sahifasi (`Routes.userReportsFilter`).
/// "Shakllantirish" bosilganda tuzilgan [UserReportFilter] `pop` orqali
/// qaytariladi; qidiruv matni ([UserReportFilter.search]) saqlanadi.
class UserReportsFilterPage extends StatelessWidget {
  const UserReportsFilterPage({required this.initial, super.key});

  final UserReportFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsFilterBloc>(
      create: (_) =>
          getIt<ReportsFilterBloc>()
            ..add(const ReportsFilterOptionsRequested()),
      child: _UserReportsFilterView(initial: initial),
    );
  }
}

class _UserReportsFilterView extends StatefulWidget {
  const _UserReportsFilterView({required this.initial});

  final UserReportFilter initial;

  @override
  State<_UserReportsFilterView> createState() => _UserReportsFilterViewState();
}

class _UserReportsFilterViewState extends State<_UserReportsFilterView> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  final Set<int> _employeeIds = {};
  int? _positionId;
  int? _regionId;
  DateTime? _joinedFromDate;
  TimeOfDay? _joinedFromTime;
  DateTime? _joinedToDate;
  TimeOfDay? _joinedToTime;

  ProjectStatus? _projectStatus;
  TaskStatus? _taskStatus;
  ReportMeetingStatus? _meetingStatus;
  ReportExpenseStatus? _expenseStatus;
  ReportPayrollType? _payrollType;

  late final _salaryFromCtrl = TextEditingController();
  late final _salaryToCtrl = TextEditingController();
  late final _balanceFromCtrl = TextEditingController();
  late final _balanceToCtrl = TextEditingController();
  late final _projectsFromCtrl = TextEditingController();
  late final _projectsToCtrl = TextEditingController();
  late final _tasksFromCtrl = TextEditingController();
  late final _tasksToCtrl = TextEditingController();
  late final _meetingsFromCtrl = TextEditingController();
  late final _meetingsToCtrl = TextEditingController();
  late final _expensesFromCtrl = TextEditingController();
  late final _expensesToCtrl = TextEditingController();
  late final _payrollsFromCtrl = TextEditingController();
  late final _payrollsToCtrl = TextEditingController();

  late String _search;

  static const _projectStatuses = [
    ProjectStatus.planning,
    ProjectStatus.active,
    ProjectStatus.overdue,
    ProjectStatus.completed,
    ProjectStatus.cancelled,
  ];
  static const _taskStatuses = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.overdue,
    TaskStatus.done,
    TaskStatus.production,
    TaskStatus.checked,
    TaskStatus.rejected,
  ];
  static const _meetingStatuses = ReportMeetingStatus.values;
  static const _expenseStatuses = ReportExpenseStatus.values;
  static const _payrollTypes = ReportPayrollType.values;

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _employeeIds.addAll(f.employeeIds);
    _positionId = f.positionId;
    _regionId = f.regionId;
    if (f.joinedFrom != null) {
      _joinedFromDate = f.joinedFrom;
      _joinedFromTime = TimeOfDay.fromDateTime(f.joinedFrom!);
    }
    if (f.joinedTo != null) {
      _joinedToDate = f.joinedTo;
      _joinedToTime = TimeOfDay.fromDateTime(f.joinedTo!);
    }
    _projectStatus = f.projectStatus;
    _taskStatus = f.taskStatus;
    _meetingStatus = f.meetingStatus;
    _expenseStatus = f.expenseStatus;
    _payrollType = f.payrollType;
    _salaryFromCtrl.text = _numText(f.salaryFrom);
    _salaryToCtrl.text = _numText(f.salaryTo);
    _balanceFromCtrl.text = _numText(f.balanceFrom);
    _balanceToCtrl.text = _numText(f.balanceTo);
    _projectsFromCtrl.text = _numText(f.projectsFrom);
    _projectsToCtrl.text = _numText(f.projectsTo);
    _tasksFromCtrl.text = _numText(f.tasksFrom);
    _tasksToCtrl.text = _numText(f.tasksTo);
    _meetingsFromCtrl.text = _numText(f.meetingsFrom);
    _meetingsToCtrl.text = _numText(f.meetingsTo);
    _expensesFromCtrl.text = _numText(f.expensesFrom);
    _expensesToCtrl.text = _numText(f.expensesTo);
    _payrollsFromCtrl.text = _numText(f.payrollsFrom);
    _payrollsToCtrl.text = _numText(f.payrollsTo);
    _search = f.search;
  }

  @override
  void dispose() {
    for (final c in [
      _salaryFromCtrl,
      _salaryToCtrl,
      _balanceFromCtrl,
      _balanceToCtrl,
      _projectsFromCtrl,
      _projectsToCtrl,
      _tasksFromCtrl,
      _tasksToCtrl,
      _meetingsFromCtrl,
      _meetingsToCtrl,
      _expensesFromCtrl,
      _expensesToCtrl,
      _payrollsFromCtrl,
      _payrollsToCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _numText(num? value) => value == null ? '' : '$value';

  num? _parseNum(String text) => num.tryParse(text.trim());

  int? _parseInt(String text) => int.tryParse(text.trim());

  // ── Dropdown ochish/yopish ────────────────────────────────────────────────

  void _toggle(_Field f) {
    FocusScope.of(context).unfocus();
    setState(() => _open = _open == f ? _Field.none : f);
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

  // ── Xodimlar — ko'p tanlov (alohida sahifa) ───────────────────────────────

  Future<void> _openEmployeeSelect(ReportsFilterState state) async {
    _close();
    final items = [
      for (final u in state.users)
        MultiSelectItem(
          id: u.id,
          initial: u.username,
          title: u.username,
          subtitle: u.position,
          avatarUrl: u.avatar,
        ),
    ];
    final l10n = AppLocalizations.of(context);
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: l10n.reportFilterEmployeesHint,
        items: items,
        selected: _employeeIds,
      ),
    );
    if (result is Set<int>) {
      setState(() {
        _employeeIds
          ..clear()
          ..addAll(result);
      });
    }
  }

  // ── Sana / vaqt ───────────────────────────────────────────────────────────

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final initial = (from ? _joinedFromDate : _joinedToDate) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _joinedFromDate = picked : _joinedToDate = picked);
    }
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (from ? _joinedFromTime : _joinedToTime) ??
          const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) {
      setState(() => from ? _joinedFromTime = picked : _joinedToTime = picked);
    }
  }

  // ── Tozalash / Shakllantirish ──────────────────────────────────────────────

  void _reset() {
    setState(() {
      _employeeIds.clear();
      _positionId = null;
      _regionId = null;
      _joinedFromDate = null;
      _joinedFromTime = null;
      _joinedToDate = null;
      _joinedToTime = null;
      _projectStatus = null;
      _taskStatus = null;
      _meetingStatus = null;
      _expenseStatus = null;
      _payrollType = null;
      for (final c in [
        _salaryFromCtrl,
        _salaryToCtrl,
        _balanceFromCtrl,
        _balanceToCtrl,
        _projectsFromCtrl,
        _projectsToCtrl,
        _tasksFromCtrl,
        _tasksToCtrl,
        _meetingsFromCtrl,
        _meetingsToCtrl,
        _expensesFromCtrl,
        _expensesToCtrl,
        _payrollsFromCtrl,
        _payrollsToCtrl,
      ]) {
        c.clear();
      }
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    DateTime? combine(DateTime? d, TimeOfDay? t) => d == null
        ? null
        : DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);

    Navigator.of(context).pop(
      UserReportFilter(
        joinedFrom: combine(_joinedFromDate, _joinedFromTime),
        joinedTo: combine(_joinedToDate, _joinedToTime),
        positionId: _positionId,
        regionId: _regionId,
        employeeIds: {..._employeeIds},
        salaryFrom: _parseNum(_salaryFromCtrl.text),
        salaryTo: _parseNum(_salaryToCtrl.text),
        balanceFrom: _parseNum(_balanceFromCtrl.text),
        balanceTo: _parseNum(_balanceToCtrl.text),
        projectStatus: _projectStatus,
        projectsFrom: _parseInt(_projectsFromCtrl.text),
        projectsTo: _parseInt(_projectsToCtrl.text),
        taskStatus: _taskStatus,
        tasksFrom: _parseInt(_tasksFromCtrl.text),
        tasksTo: _parseInt(_tasksToCtrl.text),
        meetingStatus: _meetingStatus,
        meetingsFrom: _parseInt(_meetingsFromCtrl.text),
        meetingsTo: _parseInt(_meetingsToCtrl.text),
        expenseStatus: _expenseStatus,
        expensesFrom: _parseNum(_expensesFromCtrl.text),
        expensesTo: _parseNum(_expensesToCtrl.text),
        payrollType: _payrollType,
        payrollsFrom: _parseNum(_payrollsFromCtrl.text),
        payrollsTo: _parseNum(_payrollsToCtrl.text),
        search: _search,
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
          child: BlocBuilder<ReportsFilterBloc, ReportsFilterState>(
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
                        _DateRange(
                          label: l10n.reportFilterDateRange,
                          fromDate: _fmtDate(_joinedFromDate),
                          fromTime: _fmtTime(_joinedFromTime),
                          toDate: _fmtDate(_joinedToDate),
                          toTime: _fmtTime(_joinedToTime),
                          onFromDate: () => _pickDate(true),
                          onFromTime: () => _pickTime(true),
                          onToDate: () => _pickDate(false),
                          onToTime: () => _pickTime(false),
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportFilterPosition,
                          value: _positionName(state),
                          placeholder: l10n.reportFilterPositionHint,
                          link: _links[_Field.position],
                          onTap: () => _toggle(_Field.position),
                          onClear: () => setState(() => _positionId = null),
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportFilterRegion,
                          value: _regionName(state),
                          placeholder: l10n.reportFilterRegionHint,
                          link: _links[_Field.region],
                          onTap: () => _toggle(_Field.region),
                          onClear: () => setState(() => _regionId = null),
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportFilterEmployees,
                          value: _employeeIds.isEmpty
                              ? null
                              : l10n.taskFilterSelectedCount(
                                  _employeeIds.length,
                                ),
                          placeholder: l10n.reportFilterEmployeesHint,
                          chevron: Assets.icons.icUserGroup,
                          onTap: () => _openEmployeeSelect(state),
                          onClear: () => setState(_employeeIds.clear),
                        ),
                        _AmountRange(
                          label: l10n.reportFilterSalary,
                          fromCtrl: _salaryFromCtrl,
                          toCtrl: _salaryToCtrl,
                        ),
                        _AmountRange(
                          label: l10n.reportFilterBalance,
                          fromCtrl: _balanceFromCtrl,
                          toCtrl: _balanceToCtrl,
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportProjects,
                          value: _projectStatus == null
                              ? null
                              : _projectStatusLabel(_projectStatus!, l10n),
                          placeholder: l10n.reportFilterStatusAll,
                          link: _links[_Field.projectStatus],
                          onTap: () => _toggle(_Field.projectStatus),
                          onClear: () => setState(() => _projectStatus = null),
                        ),
                        _AmountRange(
                          fromCtrl: _projectsFromCtrl,
                          toCtrl: _projectsToCtrl,
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportTasksCount,
                          value: _taskStatus == null
                              ? null
                              : _taskStatusLabel(_taskStatus!, l10n),
                          placeholder: l10n.reportFilterStatusAll,
                          link: _links[_Field.taskStatus],
                          onTap: () => _toggle(_Field.taskStatus),
                          onClear: () => setState(() => _taskStatus = null),
                        ),
                        _AmountRange(
                          fromCtrl: _tasksFromCtrl,
                          toCtrl: _tasksToCtrl,
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportMeetings,
                          value: _meetingStatus == null
                              ? null
                              : _meetingStatusLabel(_meetingStatus!, l10n),
                          placeholder: l10n.reportFilterStatusAll,
                          link: _links[_Field.meetingStatus],
                          onTap: () => _toggle(_Field.meetingStatus),
                          onClear: () => setState(() => _meetingStatus = null),
                        ),
                        _AmountRange(
                          fromCtrl: _meetingsFromCtrl,
                          toCtrl: _meetingsToCtrl,
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportFilterExpense,
                          value: _expenseStatus == null
                              ? null
                              : _expenseStatusLabel(_expenseStatus!, l10n),
                          placeholder: l10n.reportFilterStatusAll,
                          link: _links[_Field.expenseStatus],
                          onTap: () => _toggle(_Field.expenseStatus),
                          onClear: () => setState(() => _expenseStatus = null),
                        ),
                        _AmountRange(
                          fromCtrl: _expensesFromCtrl,
                          toCtrl: _expensesToCtrl,
                        ),
                        AppFilterFieldBox(
                          label: l10n.reportFilterPayroll,
                          value: _payrollType == null
                              ? null
                              : _payrollTypeLabel(_payrollType!, l10n),
                          placeholder: l10n.reportFilterStatusAll,
                          link: _links[_Field.payrollType],
                          onTap: () => _toggle(_Field.payrollType),
                          onClear: () => setState(() => _payrollType = null),
                        ),
                        _AmountRange(
                          fromCtrl: _payrollsFromCtrl,
                          toCtrl: _payrollsToCtrl,
                        ),
                      ],
                    ),
                  ),
                ),
                AppFilterActionBar(
                  resetLabel: l10n.taskFilterReset,
                  applyLabel: l10n.reportFilterGenerate,
                  applyIcon: Assets.icons.icDocument,
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

  String? _positionName(ReportsFilterState state) {
    if (_positionId == null) return null;
    for (final p in state.positions) {
      if (p.id == _positionId) return p.name;
    }
    return null;
  }

  String? _regionName(ReportsFilterState state) {
    if (_regionId == null) return null;
    for (final r in state.regions) {
      if (r.id == _regionId) return r.name;
    }
    return null;
  }

  // ── Overlay dropdown ──────────────────────────────────────────────────────

  Widget _buildOverlay(BuildContext context) {
    final link = _links[_open];
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
    final l10n = AppLocalizations.of(context);
    final state = context.read<ReportsFilterBloc>().state;

    switch (_open) {
      case _Field.position:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final p in state.positions)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: p.id == _positionId,
                onTap: () => _pick(() => _positionId = p.id),
                child: _labelRow(p.name),
              ),
          ],
        );
      case _Field.region:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final r in state.regions)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: r.id == _regionId,
                onTap: () => _pick(() => _regionId = r.id),
                child: _labelRow(r.name),
              ),
          ],
        );
      case _Field.projectStatus:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final s in _projectStatuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: s == _projectStatus,
                onTap: () => _pick(() => _projectStatus = s),
                child: _labelRow(_projectStatusLabel(s, l10n)),
              ),
          ],
        );
      case _Field.taskStatus:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final s in _taskStatuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: s == _taskStatus,
                onTap: () => _pick(() => _taskStatus = s),
                child: _labelRow(_taskStatusLabel(s, l10n)),
              ),
          ],
        );
      case _Field.meetingStatus:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final s in _meetingStatuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: s == _meetingStatus,
                onTap: () => _pick(() => _meetingStatus = s),
                child: _labelRow(_meetingStatusLabel(s, l10n)),
              ),
          ],
        );
      case _Field.expenseStatus:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final s in _expenseStatuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: s == _expenseStatus,
                onTap: () => _pick(() => _expenseStatus = s),
                child: _labelRow(_expenseStatusLabel(s, l10n)),
              ),
          ],
        );
      case _Field.payrollType:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final t in _payrollTypes)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: t == _payrollType,
                onTap: () => _pick(() => _payrollType = t),
                child: _labelRow(_payrollTypeLabel(t, l10n)),
              ),
          ],
        );
      case _Field.none:
        return const SizedBox.shrink();
    }
  }

  Widget _labelRow(String text) => text
      .s(13.sp)
      .w(700)
      .c(AppColors.of(context).textStrong)
      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);

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

// ── Enum → localizatsiya ───────────────────────────────────────────────────

String _projectStatusLabel(ProjectStatus s, AppLocalizations l10n) =>
    switch (s) {
      ProjectStatus.planning => l10n.projectStatusPlanning,
      ProjectStatus.active => l10n.projectStatusActive,
      ProjectStatus.overdue => l10n.projectStatusOverdue,
      ProjectStatus.completed => l10n.projectStatusCompleted,
      ProjectStatus.cancelled => l10n.projectStatusCancelled,
      ProjectStatus.unknown => '',
    };

String _taskStatusLabel(TaskStatus s, AppLocalizations l10n) => switch (s) {
  TaskStatus.todo => l10n.taskStatusTodo,
  TaskStatus.inProgress => l10n.taskStatusInProgress,
  TaskStatus.overdue => l10n.taskStatusOverdue,
  TaskStatus.done => l10n.taskStatusDone,
  TaskStatus.production => l10n.taskStatusProduction,
  TaskStatus.checked => l10n.taskStatusChecked,
  TaskStatus.rejected => l10n.taskStatusRejected,
  TaskStatus.unknown => '',
};

String _meetingStatusLabel(ReportMeetingStatus s, AppLocalizations l10n) =>
    switch (s) {
      ReportMeetingStatus.attended => l10n.statMeetingAttended,
      ReportMeetingStatus.absentReason => l10n.statMeetingExcused,
      ReportMeetingStatus.absentNoReason => l10n.statMeetingUnexcused,
    };

String _expenseStatusLabel(ReportExpenseStatus s, AppLocalizations l10n) =>
    switch (s) {
      ReportExpenseStatus.all => l10n.reportFilterStatusAll,
      ReportExpenseStatus.pending => l10n.reportExpenseStatusPending,
      ReportExpenseStatus.confirmed => l10n.reportExpenseStatusConfirmed,
      ReportExpenseStatus.paidUnconfirmed =>
        l10n.reportExpenseStatusPaidUnconfirmed,
      ReportExpenseStatus.cancelled => l10n.projectStatusCancelled,
    };

String _payrollTypeLabel(ReportPayrollType t, AppLocalizations l10n) =>
    switch (t) {
      ReportPayrollType.total => l10n.reportFilterStatusAll,
      ReportPayrollType.kpi => l10n.reportKpiBonus,
      ReportPayrollType.penalty => l10n.reportPayrollTypePenalty,
    };

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

// ── Sana oralig'i ────────────────────────────────────────────────────────

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.label,
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
    final l10n = AppLocalizations.of(context);
    Widget row(String date, String time, VoidCallback od, VoidCallback ot) =>
        Row(
          children: [
            Expanded(
              child: AppFilterPickerBox(
                value: date,
                placeholder: l10n.taskFilterDateHint,
                icon: Assets.icons.icCalendar,
                onTap: od,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppFilterPickerBox(
                value: time,
                placeholder: '00:00',
                icon: Assets.icons.icTuilconTime,
                onTap: ot,
              ),
            ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.h,
      children: [
        AppFilterFieldLabel(label),
        row(fromDate, fromTime, onFromDate, onFromTime),
        row(toDate, toTime, onToDate, onToTime),
      ],
    );
  }
}

// ── Son oralig'i (dan/gacha) ────────────────────────────────────────────────

/// Sonli qiymat oralig'i (dan/gacha) — sarlavha ixtiyoriy (bo'lsa yuqorida
/// mustaqil bo'lim, bo'lmasa oldingi dropdown maydonining davomi).
class _AmountRange extends StatelessWidget {
  const _AmountRange({
    required this.fromCtrl,
    required this.toCtrl,
    this.label,
  });

  final String? label;
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) AppFilterFieldLabel(label!),
        Row(
          children: [
            Expanded(
              child: _NumberField(
                controller: fromCtrl,
                hint: '${l10n.reportFilterFrom}: 0',
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _NumberField(
                controller: toCtrl,
                hint: '${l10n.reportFilterTo}: 0',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: SizedBox(
          height: 44.h,
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
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
    );
  }
}
