import 'package:flutter/material.dart';
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
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../bloc/task_filter_bloc.dart';
import 'task_multi_select_page.dart';

/// Ochilib turgan dropdown maydoni (Holati/Darajasi/Turi — bir vaqtda bittasi).
/// Loyiha/Muallif/Xodim alohida sahifada tanlanadi (dropdown emas).
enum _Field { none, status, priority, type }

/// Vazifalarni filtrlash sahifasi (`Routes.taskFilter`). "Qidirish" bosilganda
/// tuzilgan [TaskFilter] `pop` orqali qaytariladi; qidiruv matni ([TaskFilter.search])
/// saqlanadi (u sarlavhadagi qidiruv panelidan keladi).
class TaskFilterPage extends StatelessWidget {
  const TaskFilterPage({required this.initial, super.key});

  final TaskFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskFilterBloc>(
      create: (_) =>
          getIt<TaskFilterBloc>()..add(const TaskFilterOptionsRequested()),
      child: _TaskFilterView(initial: initial),
    );
  }
}

class _TaskFilterView extends StatefulWidget {
  const _TaskFilterView({required this.initial});

  final TaskFilter initial;

  @override
  State<_TaskFilterView> createState() => _TaskFilterViewState();
}

class _TaskFilterViewState extends State<_TaskFilterView> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    _Field.status: LayerLink(),
    _Field.priority: LayerLink(),
    _Field.type: LayerLink(),
  };
  _Field _open = _Field.none;

  // ── Tanlangan qiymatlar — Loyiha/Muallif/Xodim ko'p tanlov (id to'plami),
  //    sarlavhalar bloc ro'yxatidan olinadi ──────────────────────────────────
  final Set<int> _projectIds = {};
  final Set<int> _authorIds = {};
  final Set<int> _employeeIds = {};
  TaskStatus? _status;
  TaskPriority? _priority;
  TaskType? _type;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  late String _search;

  static const _priorities = [
    TaskPriority.low,
    TaskPriority.medium,
    TaskPriority.high,
    TaskPriority.critical,
  ];
  static const _types = TaskType.values;
  static const _statuses = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.overdue,
    TaskStatus.done,
    TaskStatus.production,
    TaskStatus.checked,
    TaskStatus.rejected,
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _projectIds.addAll(f.projectIds);
    _authorIds.addAll(f.createdByIds);
    _employeeIds.addAll(f.assigneeIds);
    _status = f.status;
    _priority = f.priority;
    _type = f.type;
    _search = f.search;
    if (f.deadlineFrom != null) {
      _fromDate = f.deadlineFrom;
      _fromTime = TimeOfDay.fromDateTime(f.deadlineFrom!);
    }
    if (f.deadlineTo != null) {
      _toDate = f.deadlineTo;
      _toTime = TimeOfDay.fromDateTime(f.deadlineTo!);
    }
  }

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

  // ── Ko'p tanlov (Loyiha / Muallif / Xodim) — alohida sahifa ───────────────

  Future<void> _openSelect({
    required String title,
    required List<MultiSelectItem> items,
    required Set<int> current,
  }) async {
    _close();
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: title,
        items: items,
        selected: current,
      ),
    );
    if (result is Set<int>) {
      setState(() {
        current
          ..clear()
          ..addAll(result);
      });
    }
  }

  List<MultiSelectItem> _projectItems(TaskFilterState state) => [
    for (final p in state.projects)
      MultiSelectItem(
        id: p.id,
        initial: p.title,
        title: p.title,
        subtitle: p.description,
        trailing: _fmtDate(p.deadline),
      ),
  ];

  List<MultiSelectItem> _userItems(TaskFilterState state) => [
    for (final u in state.users)
      MultiSelectItem(
        id: u.id,
        initial: u.username,
        title: u.username,
        subtitle: u.position,
      ),
  ];

  // ── Sana / vaqt ───────────────────────────────────────────────────────────

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final initial = (from ? _fromDate : _toDate) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _fromDate = picked : _toDate = picked);
    }
  }

  Future<void> _pickTime(bool from) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (from ? _fromTime : _toTime) ?? const TimeOfDay(hour: 0, minute: 0),
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) {
      setState(() => from ? _fromTime = picked : _toTime = picked);
    }
  }

  // ── Tozalash / Qidirish ───────────────────────────────────────────────────

  void _reset() {
    setState(() {
      _projectIds.clear();
      _authorIds.clear();
      _employeeIds.clear();
      _status = null;
      _priority = null;
      _type = null;
      _fromDate = null;
      _fromTime = null;
      _toDate = null;
      _toTime = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    DateTime? combine(DateTime? d, TimeOfDay? t) => d == null
        ? null
        : DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);

    Navigator.of(context).pop(
      TaskFilter(
        projectIds: {..._projectIds},
        createdByIds: {..._authorIds},
        assigneeIds: {..._employeeIds},
        status: _status,
        priority: _priority,
        type: _type,
        deadlineFrom: combine(_fromDate, _fromTime),
        deadlineTo: combine(_toDate, _toTime),
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
          child: BlocBuilder<TaskFilterBloc, TaskFilterState>(
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
                          label: l10n.taskCreateFieldProject,
                          value: _summary(
                            _projectIds,
                            _projectName(state),
                            l10n,
                          ),
                          placeholder: l10n.taskCreateProjectHint,
                          chevron: Assets.icons.icArrowRight,
                          onTap: () => _openSelect(
                            title: l10n.taskCreateProjectHint,
                            items: _projectItems(state),
                            current: _projectIds,
                          ),
                          onClear: () => setState(_projectIds.clear),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: AppFilterFieldBox(
                                label: l10n.taskFilterAuthor,
                                value: _summary(
                                  _authorIds,
                                  _userName(state),
                                  l10n,
                                ),
                                placeholder: l10n.taskFilterAuthorHint,
                                chevron: Assets.icons.icArrowRight,
                                onTap: () => _openSelect(
                                  title: l10n.taskFilterAuthorHint,
                                  items: _userItems(state),
                                  current: _authorIds,
                                ),
                                onClear: () => setState(_authorIds.clear),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: AppFilterFieldBox(
                                label: l10n.taskFilterEmployee,
                                value: _summary(
                                  _employeeIds,
                                  _userName(state),
                                  l10n,
                                ),
                                placeholder: l10n.taskFilterEmployeeHint,
                                chevron: Assets.icons.icArrowRight,
                                onTap: () => _openSelect(
                                  title: l10n.taskFilterEmployeeHint,
                                  items: _userItems(state),
                                  current: _employeeIds,
                                ),
                                onClear: () => setState(_employeeIds.clear),
                              ),
                            ),
                          ],
                        ),
                        AppFilterFieldBox(
                          label: l10n.taskFilterStatus,
                          value: _status == null
                              ? null
                              : _statusLabel(_status!, l10n),
                          placeholder: l10n.taskFilterStatusHint,
                          link: _links[_Field.status],
                          onTap: () => _toggle(_Field.status),
                          onClear: () => setState(() => _status = null),
                        ),
                        AppFilterFieldBox(
                          label: l10n.taskCreateFieldPriority,
                          value: _priority == null
                              ? null
                              : _priorityLabel(_priority!, l10n),
                          placeholder: l10n.taskCreatePriorityHint,
                          link: _links[_Field.priority],
                          onTap: () => _toggle(_Field.priority),
                          onClear: () => setState(() => _priority = null),
                        ),
                        AppFilterFieldBox(
                          label: l10n.taskCreateFieldType,
                          value:
                              _type == null ? null : _typeLabel(_type!, l10n),
                          placeholder: l10n.taskCreateTypeHint,
                          link: _links[_Field.type],
                          onTap: () => _toggle(_Field.type),
                          onClear: () => setState(() => _type = null),
                        ),
                        _DateRange(
                          label: l10n.taskFilterDeadlineRange,
                          dateHint: l10n.taskFilterDateHint,
                          fromDate: _fmtDate(_fromDate),
                          fromTime: _fmtTime(_fromTime),
                          toDate: _fmtDate(_toDate),
                          toTime: _fmtTime(_toTime),
                          onFromDate: () => _pickDate(true),
                          onFromTime: () => _pickTime(true),
                          onToDate: () => _pickDate(false),
                          onToTime: () => _pickTime(false),
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

  // ── Tanlov ko'rinishi: bo'sh → null, 1 → nom, >1 → "N ta tanlangan" ───────

  String? _summary(
    Set<int> ids,
    String? Function(int) nameOf,
    AppLocalizations l10n,
  ) {
    if (ids.isEmpty) return null;
    if (ids.length == 1) {
      return nameOf(ids.first) ?? l10n.taskFilterSelectedCount(1);
    }
    return l10n.taskFilterSelectedCount(ids.length);
  }

  String? Function(int) _projectName(TaskFilterState state) => (id) {
    for (final p in state.projects) {
      if (p.id == id) return p.title;
    }
    return null;
  };

  String? Function(int) _userName(TaskFilterState state) => (id) {
    for (final u in state.users) {
      if (u.id == id) return u.username;
    }
    return null;
  };

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

    switch (_open) {
      case _Field.priority:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final p in _priorities)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: p == _priority,
                onTap: () => _pick(() => _priority = p),
                child: _labelRow(_priorityLabel(p, l10n)),
              ),
          ],
        );
      case _Field.type:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final t in _types)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: t == _type,
                onTap: () => _pick(() => _type = t),
                child: _labelRow(_typeLabel(t, l10n)),
              ),
          ],
        );
      case _Field.status:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final s in _statuses)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: s == _status,
                onTap: () => _pick(() => _status = s),
                child: _labelRow(_statusLabel(s, l10n)),
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
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r));

    return Theme(
      data: base.copyWith(
        colorScheme: base.colorScheme.copyWith(
          primary: colors.accentSub,
          onPrimary: colors.textWhite,
          surface: colors.backgroundBase,
          onSurface: colors.textStrong,
        ),
        datePickerTheme: DatePickerThemeData(
          backgroundColor: colors.backgroundBase,
          headerBackgroundColor: colors.accentStrong,
          headerForegroundColor: colors.textWhite,
          shape: shape,
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

String _priorityLabel(TaskPriority p, AppLocalizations l10n) => switch (p) {
  TaskPriority.low => l10n.taskPriorityLow,
  TaskPriority.medium => l10n.taskPriorityMedium,
  TaskPriority.high => l10n.taskPriorityHigh,
  TaskPriority.critical => l10n.taskPriorityCritical,
  TaskPriority.unknown => '',
};

String _typeLabel(TaskType t, AppLocalizations l10n) => switch (t) {
  TaskType.bug => l10n.taskTypeBug,
  TaskType.extra => l10n.taskTypeAddition,
  TaskType.feature => l10n.taskTypeFeature,
  TaskType.research => l10n.taskTypeResearch,
};

String _statusLabel(TaskStatus s, AppLocalizations l10n) => switch (s) {
  TaskStatus.todo => l10n.taskStatusTodo,
  TaskStatus.inProgress => l10n.taskStatusInProgress,
  TaskStatus.overdue => l10n.taskStatusOverdue,
  TaskStatus.done => l10n.taskStatusDone,
  TaskStatus.production => l10n.taskStatusProduction,
  TaskStatus.checked => l10n.taskStatusChecked,
  TaskStatus.rejected => l10n.taskStatusRejected,
  TaskStatus.unknown => '',
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

// ── Sarlavha ───────────────────────────────────────────────────────────────

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
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 16.w,
                height: 16.w,
                colorFilter:
                    ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
              ),
            ),
          ),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }
}

// ── Umumiy maydon qismlari ─────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 4.h),
      child: text.s(11.sp).w(700).c(AppColors.of(context).textSub),
    );
  }
}

BoxDecoration _fieldBoxDecoration(AppColors colors) => BoxDecoration(
  color: colors.backgroundBase,
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: colors.strokeSub, width: 1.w),
);

/// Filtr tanlov maydoni: bosilganda ostidan dropdown ochiladi. Qiymat bo'lsa
/// o'ng tomonda tozalash (×) tugmasi, aks holda chevron ko'rinadi.
class _FilterBox extends StatelessWidget {
  const _FilterBox({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    required this.onClear,
    this.link,
    this.chevron,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final LayerLink? link;

  /// Bo'sh holatdagi o'ng ikonka — dropdown maydonlar uchun `null` (pastga
  /// chevron), alohida sahifaga o'tadigan maydonlar uchun o'ngga strelka.
  final SvgGenImage? chevron;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    Widget box = DecoratedBox(
      decoration: _fieldBoxDecoration(colors),
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, right: hasValue ? 6.w : 12.w),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              Expanded(
                child: (hasValue ? value! : placeholder)
                    .s(13.sp)
                    .w(700)
                    .c(hasValue ? colors.textStrong : colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 4.w),
              if (hasValue)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Assets.icons.icClose.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter:
                          ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
                    ),
                  ),
                )
              else
                (chevron ?? Assets.icons.icTuilconChervonDown).svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter:
                      ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
                ),
            ],
          ),
        ),
      ),
    );
    if (link != null) {
      box = CompositedTransformTarget(link: link!, child: box);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: box,
        ),
      ],
    );
  }
}

/// Sana/vaqt tanlagichi (dropdown emas — bosilganda picker ochiladi).
class _PickerBox extends StatelessWidget {
  const _PickerBox({
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final String placeholder;
  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: _fieldBoxDecoration(colors),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SizedBox(
            height: 44.h,
            child: Row(
              children: [
                Expanded(
                  child: (hasValue ? value : placeholder)
                      .s(13.sp)
                      .w(700)
                      .c(hasValue ? colors.textStrong : colors.textSub)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 4.w),
                icon.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter:
                      ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "Muddat oralig'i" — 2×2 (Dan: sana+vaqt, Gacha: sana+vaqt).
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
    Widget row(String date, String time, VoidCallback od, VoidCallback ot) =>
        Row(
          children: [
            Expanded(
              child: AppFilterPickerBox(
                value: date,
                placeholder: dateHint,
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
      children: [
        AppFilterFieldLabel(label),
        row(fromDate, fromTime, onFromDate, onFromTime),
        SizedBox(height: 12.h),
        row(toDate, toTime, onToDate, onToTime),
      ],
    );
  }
}

// ── Dropdown quti + qatorlar ───────────────────────────────────────────────

class _DropdownBox extends StatelessWidget {
  const _DropdownBox({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: children.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: l10n.statEmpty.s(13.sp).w(500).c(colors.textSub),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2.h,
                      children: children,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _DropdownItem extends StatelessWidget {
  const _DropdownItem({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.backgroundElevation1Alt : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          child: child,
        ),
      ),
    );
  }
}

// ── Pastki "Tozalash" + "Qidirish" tugmalari ───────────────────────────────

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.resetLabel,
    required this.applyLabel,
    required this.onReset,
    required this.onApply,
  });

  final String resetLabel;
  final String applyLabel;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onReset,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation1Alt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.icClose.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconStrong,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        resetLabel.s(15.sp).w(800).c(colors.textStrong),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: InkWell(
                onTap: onApply,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentStrong,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.icSearch.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.textWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        applyLabel.s(15.sp).w(800).c(colors.textWhite),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
