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
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/payroll_report_filter.dart';
import '../bloc/project_reports_filter_bloc.dart';

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field { none, month, status }

/// Ish haqi hisoboti filtri sahifasi (`Routes.payrollReportsFilter`).
/// Xodimlar/Hisobchi — ko'p-tanlov, alohida sahifada (`TaskMultiSelectPage`);
/// Oy/Holati — bitta tanlov dropdown. Tanlov ro'yxati (foydalanuvchilar)
/// [ProjectReportsFilterBloc]dan qayta ishlatiladi — u ham xuddi shu
/// `GET /users/all/` ro'yxatini yuklaydi.
class PayrollReportsFilterPage extends StatelessWidget {
  const PayrollReportsFilterPage({required this.initial, super.key});
  final PayrollReportFilter initial;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ProjectReportsFilterBloc>()
          ..add(const ProjectReportsFilterOptionsRequested()),
    child: _View(initial: initial),
  );
}

class _View extends StatefulWidget {
  const _View({required this.initial});
  final PayrollReportFilter initial;
  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  final Set<int> _users = {};
  final Set<int> _accountants = {};
  int? _month;
  bool? _isConfirmed;
  DateTime? _createdFrom, _createdTo, _confirmedFrom, _confirmedTo;

  late final _totalFrom = TextEditingController(
    text: _num(widget.initial.totalFrom),
  );
  late final _totalTo = TextEditingController(
    text: _num(widget.initial.totalTo),
  );
  late final _salaryFrom = TextEditingController(
    text: _num(widget.initial.salaryFrom),
  );
  late final _salaryTo = TextEditingController(
    text: _num(widget.initial.salaryTo),
  );
  late final _kpiFrom = TextEditingController(
    text: _num(widget.initial.kpiFrom),
  );
  late final _kpiTo = TextEditingController(text: _num(widget.initial.kpiTo));
  late final _penaltyFrom = TextEditingController(
    text: _num(widget.initial.penaltyFrom),
  );
  late final _penaltyTo = TextEditingController(
    text: _num(widget.initial.penaltyTo),
  );

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _users.addAll(f.userIds);
    _accountants.addAll(f.accountantIds);
    _month = f.month;
    _isConfirmed = f.isConfirmed;
    _createdFrom = f.createdFrom;
    _createdTo = f.createdTo;
    _confirmedFrom = f.confirmedFrom;
    _confirmedTo = f.confirmedTo;
  }

  @override
  void dispose() {
    for (final c in [
      _totalFrom,
      _totalTo,
      _salaryFrom,
      _salaryTo,
      _kpiFrom,
      _kpiTo,
      _penaltyFrom,
      _penaltyTo,
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

  // ── Xodimlar/Hisobchi — alohida sahifa ────────────────────────────────────

  Future<void> _openSelect({
    required String title,
    required Set<int> current,
  }) async {
    _close();
    final state = context.read<ProjectReportsFilterBloc>().state;
    final result = await context.pushNamed<Object?>(
      Routes.taskMultiSelect.name,
      extra: TaskMultiSelectArgs(
        title: title,
        items: [
          for (final u in state.users)
            MultiSelectItem(
              id: u.id,
              initial: u.username,
              title: u.username,
              subtitle: u.position,
              avatarUrl: u.avatar,
            ),
        ],
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
      _users.clear();
      _accountants.clear();
      _month = null;
      _isConfirmed = null;
      _createdFrom = _createdTo = _confirmedFrom = _confirmedTo = null;
      for (final c in [
        _totalFrom,
        _totalTo,
        _salaryFrom,
        _salaryTo,
        _kpiFrom,
        _kpiTo,
        _penaltyFrom,
        _penaltyTo,
      ]) {
        c.clear();
      }
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() => Navigator.of(context).pop(
    PayrollReportFilter(
      search: widget.initial.search,
      createdFrom: _createdFrom,
      createdTo: _createdTo,
      confirmedFrom: _confirmedFrom,
      confirmedTo: _confirmedTo,
      userIds: {..._users},
      accountantIds: {..._accountants},
      month: _month,
      isConfirmed: _isConfirmed,
      totalFrom: _parseAmount(_totalFrom.text),
      totalTo: _parseAmount(_totalTo.text),
      salaryFrom: _parseAmount(_salaryFrom.text),
      salaryTo: _parseAmount(_salaryTo.text),
      kpiFrom: _parseAmount(_kpiFrom.text),
      kpiTo: _parseAmount(_kpiTo.text),
      penaltyFrom: _parseAmount(_penaltyFrom.text),
      penaltyTo: _parseAmount(_penaltyTo.text),
    ),
  );

  String _statusLabel(bool value, AppLocalizations l10n) =>
      value ? l10n.payrollStatusConfirmed : l10n.payrollStatusCalculated;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).backgroundBase,
      body: SafeArea(
        child: OverlayPortal(
          controller: _portalCtrl,
          overlayChildBuilder: _buildOverlay,
          child: Column(
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
                        label: l10n.payrollCreatedAt,
                        from: _createdFrom,
                        to: _createdTo,
                        onFrom: () => _date((v) => _createdFrom = v),
                        onTo: () => _date((v) => _createdTo = v),
                      ),
                      _Dates(
                        label: l10n.expenseReportConfirmedAt,
                        from: _confirmedFrom,
                        to: _confirmedTo,
                        onFrom: () => _date((v) => _confirmedFrom = v),
                        onTo: () => _date((v) => _confirmedTo = v),
                      ),
                      AppFilterFieldBox(
                        label: l10n.reportFilterEmployees,
                        value: _users.isEmpty
                            ? null
                            : l10n.taskFilterSelectedCount(_users.length),
                        placeholder: l10n.reportFilterEmployeesHint,
                        chevron: Assets.icons.icUserGroup,
                        onTap: () => _openSelect(
                          title: l10n.reportFilterEmployeesHint,
                          current: _users,
                        ),
                        onClear: () => setState(_users.clear),
                      ),
                      AppFilterFieldBox(
                        label: l10n.expenseReportAccountant,
                        value: _accountants.isEmpty
                            ? null
                            : l10n.taskFilterSelectedCount(_accountants.length),
                        placeholder: l10n.expenseReportAccountantHint,
                        chevron: Assets.icons.icUserGroup,
                        onTap: () => _openSelect(
                          title: l10n.expenseReportAccountantHint,
                          current: _accountants,
                        ),
                        onClear: () => setState(_accountants.clear),
                      ),
                      AppFilterFieldBox(
                        label: l10n.payrollMonth,
                        value: _month == null ? null : uzMonthName(_month!),
                        placeholder: l10n.expenseReportSelect,
                        link: _links[_Field.month],
                        onTap: () => _toggle(_Field.month),
                        onClear: () => setState(() => _month = null),
                      ),
                      AppFilterFieldBox(
                        label: l10n.taskFilterStatus,
                        value: _isConfirmed == null
                            ? null
                            : _statusLabel(_isConfirmed!, l10n),
                        placeholder: l10n.taskFilterStatusHint,
                        link: _links[_Field.status],
                        onTap: () => _toggle(_Field.status),
                        onClear: () => setState(() => _isConfirmed = null),
                      ),
                      _Range(
                        label: l10n.payrollTotal,
                        from: _totalFrom,
                        to: _totalTo,
                      ),
                      _Range(
                        label: l10n.payrollFixedSalary,
                        from: _salaryFrom,
                        to: _salaryTo,
                      ),
                      _Range(
                        label: l10n.payrollKpiBonus,
                        from: _kpiFrom,
                        to: _kpiTo,
                      ),
                      _Range(
                        label: l10n.payrollPenalty,
                        from: _penaltyFrom,
                        to: _penaltyTo,
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

    switch (_open) {
      case _Field.month:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (var m = 1; m <= 12; m++)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: m == _month,
                onTap: () => _pick(() => _month = m),
                child: _labelRow(uzMonthName(m)),
              ),
          ],
        );
      case _Field.status:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final v in const [false, true])
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: v == _isConfirmed,
                onTap: () => _pick(() => _isConfirmed = v),
                child: _labelRow(_statusLabel(v, l10n)),
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

// ── Summa oralig'i (dan/gacha, minglik formatli) ────────────────────────────

class _Range extends StatelessWidget {
  const _Range({required this.label, required this.from, required this.to});
  final String label;
  final TextEditingController from, to;
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
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _Number(controller: to, hint: '${l.reportFilterTo}: 0'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;
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
              inputFormatters: [AppThousandsInputFormatter()],
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
