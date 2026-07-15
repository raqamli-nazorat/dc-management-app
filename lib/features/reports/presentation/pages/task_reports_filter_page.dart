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
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/task_report_filter.dart';
import '../bloc/task_reports_filter_bloc.dart';

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field { none, priority, status, type, sprint, position }

/// Vazifa hisoboti filtri sahifasi (`Routes.taskReportsFilter`).
/// Loyihalar/Topshiruvchilar/Muallif — ko'p-tanlov, alohida sahifada
/// (`TaskMultiSelectPage`). Darajasi/Holati — bitta tanlov dropdown;
/// Turi/Sprint/Kim uchun — API massiv qabul qilgani uchun ko'p-tanlov dropdown.
class TaskReportsFilterPage extends StatelessWidget {
  const TaskReportsFilterPage({required this.initial, super.key});
  final TaskReportFilter initial;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<TaskReportsFilterBloc>()
          ..add(const TaskReportsFilterOptionsRequested()),
    child: _View(initial: initial),
  );
}

class _View extends StatefulWidget {
  const _View({required this.initial});
  final TaskReportFilter initial;
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  final Set<int> _projects = {};
  final Set<int> _assignees = {};
  final Set<int> _authors = {};
  TaskPriority? _priority;
  TaskStatus? _status;
  final Set<TaskType> _types = {};
  final Set<int> _sprints = {};
  final Set<int> _positions = {};
  DateTime? _createdFrom, _createdTo;

  late final _priceFrom = TextEditingController(
    text: _num(widget.initial.priceFrom),
  );
  late final _priceTo = TextEditingController(
    text: _num(widget.initial.priceTo),
  );
  late final _penaltyFrom = TextEditingController(
    text: _num(widget.initial.penaltyFrom),
  );
  late final _penaltyTo = TextEditingController(
    text: _num(widget.initial.penaltyTo),
  );
  late final _reopenedFrom = TextEditingController(
    text: _num(widget.initial.reopenedFrom),
  );
  late final _reopenedTo = TextEditingController(
    text: _num(widget.initial.reopenedTo),
  );

  static const _priorities = [
    TaskPriority.low,
    TaskPriority.medium,
    TaskPriority.high,
    TaskPriority.critical,
  ];
  static const _statuses = [
    TaskStatus.todo,
    TaskStatus.inProgress,
    TaskStatus.overdue,
    TaskStatus.done,
    TaskStatus.production,
    TaskStatus.checked,
    TaskStatus.rejected,
  ];
  static const _typeValues = TaskType.values;
  static final _sprintValues = List<int>.generate(10, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _projects.addAll(f.projectIds);
    _assignees.addAll(f.assigneeIds);
    _authors.addAll(f.authorIds);
    _priority = f.priority;
    _status = f.status;
    _types.addAll(f.types);
    _sprints.addAll(f.sprints);
    _positions.addAll(f.positionIds);
    _createdFrom = f.createdFrom;
    _createdTo = f.createdTo;
  }

  @override
  void dispose() {
    for (final c in [
      _priceFrom,
      _priceTo,
      _penaltyFrom,
      _penaltyTo,
      _reopenedFrom,
      _reopenedTo,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  static String _num(num? value) => value?.toString() ?? '';

  static num? _parseAmount(String text) =>
      num.tryParse(text.replaceAll(' ', ''));

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

  /// Ko'p-tanlov dropdown elementi — dropdown ochiq qoladi.
  void _toggleMulti<T>(Set<T> selected, T value) => setState(
    () => selected.contains(value)
        ? selected.remove(value)
        : selected.add(value),
  );

  // ── Loyihalar/Topshiruvchilar/Muallif — alohida sahifa ────────────────────

  Future<void> _openSelect({
    required String title,
    required Set<int> current,
    required List<MultiSelectItem> items,
  }) async {
    _close();
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(title: title, items: items, selected: current),
    );
    if (result is Set<int>) {
      setState(() {
        current
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _date(void Function(DateTime?) set) async {
    final now = DateTime.now();
    final date = await showAppDatePicker(
      context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) setState(() => set(date));
  }

  void _reset() {
    setState(() {
      _projects.clear();
      _assignees.clear();
      _authors.clear();
      _priority = null;
      _status = null;
      _types.clear();
      _sprints.clear();
      _positions.clear();
      _createdFrom = _createdTo = null;
      for (final c in [
        _priceFrom,
        _priceTo,
        _penaltyFrom,
        _penaltyTo,
        _reopenedFrom,
        _reopenedTo,
      ]) {
        c.clear();
      }
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() => Navigator.of(context).pop(
    TaskReportFilter(
      search: widget.initial.search,
      createdFrom: _createdFrom,
      createdTo: _createdTo,
      projectIds: {..._projects},
      assigneeIds: {..._assignees},
      authorIds: {..._authors},
      priority: _priority,
      status: _status,
      types: {..._types},
      sprints: {..._sprints},
      positionIds: {..._positions},
      priceFrom: _parseAmount(_priceFrom.text),
      priceTo: _parseAmount(_priceTo.text),
      penaltyFrom: num.tryParse(_penaltyFrom.text),
      penaltyTo: num.tryParse(_penaltyTo.text),
      reopenedFrom: int.tryParse(_reopenedFrom.text),
      reopenedTo: int.tryParse(_reopenedTo.text),
    ),
  );

  String? _multiSummary(Set<int> ids, AppLocalizations l10n) =>
      ids.isEmpty ? null : l10n.taskFilterSelectedCount(ids.length);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).backgroundBase,
      body: SafeArea(
        child: OverlayPortal(
          controller: _portalCtrl,
          overlayChildBuilder: _buildOverlay,
          child: BlocBuilder<TaskReportsFilterBloc, TaskReportsFilterState>(
            builder: (context, state) {
              final userItems = [
                for (final u in state.users)
                  MultiSelectItem(
                    id: u.id,
                    initial: u.username,
                    title: u.username,
                    subtitle: u.position,
                    avatarUrl: u.avatar,
                  ),
              ];
              return Column(
                children: [
                  AppFilterHeader(title: l10n.taskFilterTitle),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12.h,
                        children: [
                          _Dates(
                            label: l10n.expenseReportCreatedAt,
                            from: _createdFrom,
                            to: _createdTo,
                            onFrom: () => _date((v) => _createdFrom = v),
                            onTo: () => _date((v) => _createdTo = v),
                          ),
                          AppFilterFieldBox(
                            label: l10n.reportProjects,
                            value: _multiSummary(_projects, l10n),
                            placeholder: l10n.expenseReportProjectHint,
                            chevron: Assets.icons.icBreifcase,
                            onTap: () => _openSelect(
                              title: l10n.expenseReportProjectHint,
                              current: _projects,
                              items: [
                                for (final p in state.projects)
                                  MultiSelectItem(
                                    id: p.id,
                                    initial: p.title,
                                    title: p.title,
                                    subtitle: p.description,
                                  ),
                              ],
                            ),
                            onClear: () => setState(_projects.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskReportAssignees,
                            value: _multiSummary(_assignees, l10n),
                            placeholder: l10n.taskReportAssigneesHint,
                            chevron: Assets.icons.icUserGroup,
                            onTap: () => _openSelect(
                              title: l10n.taskReportAssigneesHint,
                              current: _assignees,
                              items: userItems,
                            ),
                            onClear: () => setState(_assignees.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.reportFilterAuthor,
                            value: _multiSummary(_authors, l10n),
                            placeholder: l10n.taskFilterAuthorHint,
                            chevron: Assets.icons.icUserGroup,
                            onTap: () => _openSelect(
                              title: l10n.taskFilterAuthorHint,
                              current: _authors,
                              items: userItems,
                            ),
                            onClear: () => setState(_authors.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskCreateFieldPriority,
                            value: _priority == null
                                ? null
                                : _priorityLabel(_priority!, l10n),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.priority],
                            onTap: () => _toggle(_Field.priority),
                            onClear: () => setState(() => _priority = null),
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
                            label: l10n.taskCreateFieldType,
                            value: _types.isEmpty
                                ? null
                                : _types
                                      .map((t) => _typeLabel(t, l10n))
                                      .join(', '),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.type],
                            onTap: () => _toggle(_Field.type),
                            onClear: () => setState(_types.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskReportSprint,
                            value: _sprints.isEmpty
                                ? null
                                : (_sprints.toList()..sort())
                                      .map((n) => '$n-sprint')
                                      .join(', '),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.sprint],
                            onTap: () => _toggle(_Field.sprint),
                            onClear: () => setState(_sprints.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskCreateFieldPositions,
                            value: _positions.isEmpty
                                ? null
                                : state.positions
                                      .where((p) => _positions.contains(p.id))
                                      .map((p) => p.name)
                                      .join(', '),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.position],
                            onTap: () => _toggle(_Field.position),
                            onClear: () => setState(_positions.clear),
                          ),
                          _Range(
                            label: l10n.taskReportPrice,
                            from: _priceFrom,
                            to: _priceTo,
                            thousands: true,
                          ),
                          _Range(
                            label: l10n.taskReportPenalty,
                            from: _penaltyFrom,
                            to: _penaltyTo,
                          ),
                          _Range(
                            label: l10n.taskReportReopened,
                            from: _reopenedFrom,
                            to: _reopenedTo,
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
              );
            },
          ),
        ),
      ),
    );
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
    final state = context.read<TaskReportsFilterBloc>().state;

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
      case _Field.type:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final t in _typeValues)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: _types.contains(t),
                onTap: () => _toggleMulti(_types, t),
                child: _labelRow(_typeLabel(t, l10n)),
              ),
          ],
        );
      case _Field.sprint:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final n in _sprintValues)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: _sprints.contains(n),
                onTap: () => _toggleMulti(_sprints, n),
                child: _labelRow('$n-sprint'),
              ),
          ],
        );
      case _Field.position:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final p in state.positions)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: _positions.contains(p.id),
                onTap: () => _toggleMulti(_positions, p.id),
                child: _labelRow(p.name),
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
}

// ── Enum → localizatsiya ───────────────────────────────────────────────────

String _priorityLabel(TaskPriority value, AppLocalizations l10n) =>
    switch (value) {
      TaskPriority.low => l10n.taskPriorityLow,
      TaskPriority.medium => l10n.taskPriorityMedium,
      TaskPriority.high => l10n.taskPriorityHigh,
      TaskPriority.critical => l10n.taskPriorityCritical,
      TaskPriority.unknown => '',
    };

String _statusLabel(TaskStatus value, AppLocalizations l10n) => switch (value) {
  TaskStatus.todo => l10n.taskStatusTodo,
  TaskStatus.inProgress => l10n.taskStatusInProgress,
  TaskStatus.overdue => l10n.taskStatusOverdue,
  TaskStatus.done => l10n.taskStatusDone,
  TaskStatus.production => l10n.taskStatusProduction,
  TaskStatus.checked => l10n.taskStatusChecked,
  TaskStatus.rejected => l10n.taskStatusRejected,
  TaskStatus.unknown => '',
};

String _typeLabel(TaskType value, AppLocalizations l10n) => switch (value) {
  TaskType.bug => l10n.taskTypeBug,
  TaskType.extra => l10n.taskTypeAddition,
  TaskType.feature => l10n.taskTypeFeature,
  TaskType.research => l10n.taskTypeResearch,
};

// ── Sana oralig'i (faqat sana) ──────────────────────────────────────────────

class _Dates extends StatelessWidget {
  const _Dates({
    required this.label,
    required this.from,
    required this.to,
    required this.onFrom,
    required this.onTo,
  });
  final String label;
  final DateTime? from, to;
  final VoidCallback onFrom, onTo;
  String _format(DateTime? date) => date == null
      ? ''
      : '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        Row(
          children: [
            Expanded(
              child: AppFilterPickerBox(
                value: _format(from),
                placeholder: '${l.reportFilterFrom}: ${l.taskFilterDateHint}',
                icon: Assets.icons.icCalendar,
                onTap: onFrom,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppFilterPickerBox(
                value: _format(to),
                placeholder: '${l.reportFilterTo}: ${l.taskFilterDateHint}',
                icon: Assets.icons.icCalendar,
                onTap: onTo,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Son oralig'i (dan/gacha) ────────────────────────────────────────────────

class _Range extends StatelessWidget {
  const _Range({
    required this.label,
    required this.from,
    required this.to,
    this.thousands = false,
  });
  final String label;
  final TextEditingController from, to;
  final bool thousands;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        Row(
          children: [
            Expanded(
              child: _Number(
                controller: from,
                hint: '${l.reportFilterFrom}: 0',
                thousands: thousands,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _Number(
                controller: to,
                hint: '${l.reportFilterTo}: 0',
                thousands: thousands,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({
    required this.controller,
    required this.hint,
    required this.thousands,
  });
  final TextEditingController controller;
  final String hint;
  final bool thousands;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
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
              keyboardType: TextInputType.number,
              inputFormatters: [
                if (thousands)
                  AppThousandsInputFormatter()
                else
                  FilteringTextInputFormatter.digitsOnly,
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
