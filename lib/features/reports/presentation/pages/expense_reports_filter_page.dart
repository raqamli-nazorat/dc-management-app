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
import '../../../tasks/presentation/pages/task_multi_select_page.dart';
import '../../domain/entities/expense_report.dart';
import '../../domain/entities/expense_report_filter.dart';
import '../bloc/expense_reports_filter_bloc.dart';

/// So'ralayotgan/kiritayotgan summani yuzlab guruhlab ko'rsatadi (`10000` →
/// `10 000`) — kursor har doim oxirga o'tadi, filtr "dan/gacha" maydoni uchun
/// yetarli.
class _ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field { none, paymentMethod, status, type, category }

/// Xarajat so'rovlari bo'yicha filtrlash sahifasi (`Routes.expenseReportsFilter`).
/// Xodim/Hisobchi/Loyiha — ko'p-tanlov, alohida sahifada (`TaskMultiSelectPage`).
/// To'lov turi/Holati/Xarajat turi/Toifa — bir-tanlov, sahifa ichidagi dropdown.
class ExpenseReportsFilterPage extends StatelessWidget {
  const ExpenseReportsFilterPage({required this.initial, super.key});
  final ExpenseReportFilter initial;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ExpenseReportsFilterBloc>()
          ..add(const ExpenseReportsFilterOptionsRequested()),
    child: _View(initial: initial),
  );
}

class _View extends StatefulWidget {
  const _View({required this.initial});
  final ExpenseReportFilter initial;
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
  final Set<int> _projects = {};
  int? _categoryId;
  ExpensePaymentMethod? _paymentMethod;
  ExpenseStatus? _status;
  ExpenseType? _type;

  late final _amountFrom = TextEditingController(
    text: _num(widget.initial.amountFrom),
  );
  late final _amountTo = TextEditingController(
    text: _num(widget.initial.amountTo),
  );
  late final _searchCtrl = TextEditingController(text: widget.initial.search);

  DateTime? _createdFrom,
      _createdTo,
      _paidFrom,
      _paidTo,
      _confirmedFrom,
      _confirmedTo,
      _cancelledFrom,
      _cancelledTo;

  static const _paymentMethods = [
    ExpensePaymentMethod.cash,
    ExpensePaymentMethod.card,
  ];
  static const _statuses = [
    ExpenseStatus.pending,
    ExpenseStatus.paid,
    ExpenseStatus.confirmed,
    ExpenseStatus.cancelled,
  ];
  static const _types = [
    ExpenseType.company,
    ExpenseType.withdrawal,
    ExpenseType.other,
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _users.addAll(f.userIds);
    _accountants.addAll(f.accountantIds);
    _projects.addAll(f.projectIds);
    _categoryId = f.categoryIds.isEmpty ? null : f.categoryIds.first;
    _paymentMethod = f.paymentMethods.isEmpty ? null : f.paymentMethods.first;
    _status = f.statuses.isEmpty ? null : f.statuses.first;
    _type = f.types.isEmpty ? null : f.types.first;
    _createdFrom = f.createdFrom;
    _createdTo = f.createdTo;
    _paidFrom = f.paidFrom;
    _paidTo = f.paidTo;
    _confirmedFrom = f.confirmedFrom;
    _confirmedTo = f.confirmedTo;
    _cancelledFrom = f.cancelledFrom;
    _cancelledTo = f.cancelledTo;
  }

  @override
  void dispose() {
    _amountFrom.dispose();
    _amountTo.dispose();
    _searchCtrl.dispose();
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

  // ── Xodim/Hisobchi/Loyiha — ko'p tanlov (alohida sahifa) ───────────────────

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
      _users.clear();
      _accountants.clear();
      _projects.clear();
      _categoryId = null;
      _paymentMethod = null;
      _status = null;
      _type = null;
      _amountFrom.clear();
      _amountTo.clear();
      _searchCtrl.clear();
      _createdFrom = _createdTo = _paidFrom = _paidTo = _confirmedFrom =
          _confirmedTo = _cancelledFrom = _cancelledTo = null;
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() => Navigator.of(context).pop(
    ExpenseReportFilter(
      search: _searchCtrl.text.trim(),
      userIds: {..._users},
      accountantIds: {..._accountants},
      projectIds: {..._projects},
      categoryIds: _categoryId == null ? const {} : {_categoryId!},
      paymentMethods: _paymentMethod == null ? const {} : {_paymentMethod!},
      statuses: _status == null ? const {} : {_status!},
      types: _type == null ? const {} : {_type!},
      amountFrom: _parseAmount(_amountFrom.text),
      amountTo: _parseAmount(_amountTo.text),
      createdFrom: _createdFrom,
      createdTo: _createdTo,
      paidFrom: _paidFrom,
      paidTo: _paidTo,
      confirmedFrom: _confirmedFrom,
      confirmedTo: _confirmedTo,
      cancelledFrom: _cancelledFrom,
      cancelledTo: _cancelledTo,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).backgroundBase,
      body: SafeArea(
        child: OverlayPortal(
          controller: _portalCtrl,
          overlayChildBuilder: _buildOverlay,
          child: BlocBuilder<ExpenseReportsFilterBloc, ExpenseReportsFilterState>(
            builder: (context, state) {
              final options = state.options;
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
                          _Dates(
                            label: l10n.expenseReportConfirmedAt,
                            from: _confirmedFrom,
                            to: _confirmedTo,
                            onFrom: () => _date((v) => _confirmedFrom = v),
                            onTo: () => _date((v) => _confirmedTo = v),
                          ),
                          _Dates(
                            label: l10n.expenseReportPaidAt,
                            from: _paidFrom,
                            to: _paidTo,
                            onFrom: () => _date((v) => _paidFrom = v),
                            onTo: () => _date((v) => _paidTo = v),
                          ),
                          _Dates(
                            label: l10n.expenseReportCancelledAt,
                            from: _cancelledFrom,
                            to: _cancelledTo,
                            onFrom: () => _date((v) => _cancelledFrom = v),
                            onTo: () => _date((v) => _cancelledTo = v),
                          ),
                          _Amount(from: _amountFrom, to: _amountTo),
                          AppFilterFieldBox(
                            label: l10n.expenseReportPaymentMethod,
                            value: _paymentMethod == null
                                ? null
                                : _paymentLabel(_paymentMethod!, l10n),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.paymentMethod],
                            onTap: () => _toggle(_Field.paymentMethod),
                            onClear: () => setState(() => _paymentMethod = null),
                          ),
                          AppFilterFieldBox(
                            label: l10n.taskFilterStatus,
                            value: _status == null
                                ? null
                                : _statusLabel(_status!, l10n),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.status],
                            onTap: () => _toggle(_Field.status),
                            onClear: () => setState(() => _status = null),
                          ),
                          _TitleField(
                            label: l10n.expenseReportTitle,
                            controller: _searchCtrl,
                            hint: l10n.expenseReportTitleHint,
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
                              items: userItems,
                            ),
                            onClear: () => setState(_users.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.expenseReportAccountant,
                            value: _accountants.isEmpty
                                ? null
                                : l10n.taskFilterSelectedCount(
                                    _accountants.length,
                                  ),
                            placeholder: l10n.expenseReportAccountantHint,
                            chevron: Assets.icons.icUserGroup,
                            onTap: () => _openSelect(
                              title: l10n.expenseReportAccountantHint,
                              current: _accountants,
                              items: userItems,
                            ),
                            onClear: () => setState(_accountants.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.expenseReportProject,
                            value: _projects.isEmpty
                                ? null
                                : l10n.taskFilterSelectedCount(_projects.length),
                            placeholder: l10n.expenseReportProjectHint,
                            chevron: Assets.icons.icBreifcase,
                            onTap: () => _openSelect(
                              title: l10n.expenseReportProjectHint,
                              current: _projects,
                              items: [
                                for (final p in options?.projects ?? const [])
                                  MultiSelectItem(
                                    id: p.id,
                                    initial: p.title,
                                    title: p.title,
                                  ),
                              ],
                            ),
                            onClear: () => setState(_projects.clear),
                          ),
                          AppFilterFieldBox(
                            label: l10n.expenseReportType,
                            value: _type == null
                                ? null
                                : _typeLabel(_type!, l10n),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.type],
                            onTap: () => _toggle(_Field.type),
                            onClear: () => setState(() => _type = null),
                          ),
                          AppFilterFieldBox(
                            label: l10n.expenseReportCategory,
                            value: _categoryName(options),
                            placeholder: l10n.expenseReportSelect,
                            link: _links[_Field.category],
                            onTap: () => _toggle(_Field.category),
                            onClear: () => setState(() => _categoryId = null),
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

  String? _categoryName(ExpenseReportOptions? options) {
    if (_categoryId == null || options == null) return null;
    for (final c in options.categories) {
      if (c.id == _categoryId) return c.title;
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
    final options = context.read<ExpenseReportsFilterBloc>().state.options;

    switch (_open) {
      case _Field.paymentMethod:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final m in _paymentMethods)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: m == _paymentMethod,
                onTap: () => _pick(() => _paymentMethod = m),
                child: _labelRow(_paymentLabel(m, l10n)),
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
            for (final t in _types)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: t == _type,
                onTap: () => _pick(() => _type = t),
                child: _labelRow(_typeLabel(t, l10n)),
              ),
          ],
        );
      case _Field.category:
        final categories = options?.categories ?? const [];
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final c in categories)
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: c.id == _categoryId,
                onTap: () => _pick(() => _categoryId = c.id),
                child: _labelRow(c.title),
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

String _paymentLabel(ExpensePaymentMethod value, AppLocalizations l10n) =>
    switch (value) {
      ExpensePaymentMethod.cash => l10n.expenseReportPaymentCash,
      ExpensePaymentMethod.card => l10n.expenseReportPaymentCard,
      ExpensePaymentMethod.unknown => '',
    };

String _statusLabel(ExpenseStatus value, AppLocalizations l10n) =>
    switch (value) {
      ExpenseStatus.pending => l10n.expenseReportStatusPending,
      ExpenseStatus.paid => l10n.expenseReportStatusPaid,
      ExpenseStatus.confirmed => l10n.expenseReportStatusConfirmed,
      ExpenseStatus.cancelled => l10n.expenseReportStatusCancelled,
      ExpenseStatus.unknown => '',
    };

String _typeLabel(ExpenseType value, AppLocalizations l10n) => switch (value) {
  ExpenseType.withdrawal => l10n.expenseReportTypeWithdrawal,
  ExpenseType.company => l10n.expenseReportTypeCompany,
  ExpenseType.other => l10n.expenseReportTypeOther,
  ExpenseType.unknown => '',
};

// ── Sana oralig'i (faqat sana, vaqtsiz) ─────────────────────────────────────

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

class _Amount extends StatelessWidget {
  const _Amount({required this.from, required this.to});
  final TextEditingController from, to;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(l.expenseReportAmount),
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
              inputFormatters: [_ThousandsInputFormatter()],
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

// ── Erkin matn (Titul / qidiruv) ────────────────────────────────────────────

class _TitleField extends StatelessWidget {
  const _TitleField({
    required this.label,
    required this.controller,
    required this.hint,
  });
  final String label;
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SizedBox(
              height: 44.h,
              child: Center(
                child: TextField(
                  controller: controller,
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
