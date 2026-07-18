import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/expense_report.dart';
import '../../../reports/domain/entities/expense_report_filter.dart';
import '../../domain/entities/expense_request_filter.dart';
import '../bloc/expense_request_options_bloc.dart';

/// Ochilib turgan dropdown maydoni — bir vaqtda bittasi.
enum _Field { none, type, category, project }

/// Vaqt oralig'i maydonlari (3 ta bir xil blok).
enum _Range { created, paid, confirmed }

/// Xarajat so'rovlarini filtrlash sahifasi (`Routes.expenseRequestsFilter`,
/// Figma: node 334-79368 / 2796-296889). Xarajat turi + Toifa + Loyiha
/// dropdownlari, summa oralig'i va uchta sana-vaqt oralig'i (yaratilgan /
/// to'langan / tasdiqlangan). Vaqt faqat qo'lda kiritiladi (input rejimi).
/// "Shakllantirish" bosilganda [ExpenseRequestFilter] `pop` orqali
/// qaytariladi; qidiruv matni saqlanadi.
class ExpenseRequestsFilterPage extends StatelessWidget {
  const ExpenseRequestsFilterPage({required this.initial, super.key});

  final ExpenseRequestFilter initial;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseRequestOptionsBloc>(
      create: (_) =>
          getIt<ExpenseRequestOptionsBloc>()
            ..add(const ExpenseRequestOptionsRequested()),
      child: _ExpenseRequestsFilterView(initial: initial),
    );
  }
}

class _ExpenseRequestsFilterView extends StatefulWidget {
  const _ExpenseRequestsFilterView({required this.initial});

  final ExpenseRequestFilter initial;

  @override
  State<_ExpenseRequestsFilterView> createState() =>
      _ExpenseRequestsFilterViewState();
}

class _ExpenseRequestsFilterViewState
    extends State<_ExpenseRequestsFilterView> {
  final _portalCtrl = OverlayPortalController();
  final Map<_Field, LayerLink> _links = {
    for (final f in _Field.values.skip(1)) f: LayerLink(),
  };
  _Field _open = _Field.none;

  ExpenseType? _type;
  int? _categoryId;
  int? _projectId;
  late final _amountFromCtrl = TextEditingController();
  late final _amountToCtrl = TextEditingController();

  final Map<_Range, DateTime?> _fromDate = {
    for (final r in _Range.values) r: null,
  };
  final Map<_Range, TimeOfDay?> _fromTime = {
    for (final r in _Range.values) r: null,
  };
  final Map<_Range, DateTime?> _toDate = {
    for (final r in _Range.values) r: null,
  };
  final Map<_Range, TimeOfDay?> _toTime = {
    for (final r in _Range.values) r: null,
  };

  static const _types = [
    ExpenseType.withdrawal,
    ExpenseType.company,
    ExpenseType.other,
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _type = f.type;
    _categoryId = f.categoryId;
    _projectId = f.projectId;
    _amountFromCtrl.text = _numText(f.amountFrom);
    _amountToCtrl.text = _numText(f.amountTo);
    void seed(_Range r, DateTime? from, DateTime? to) {
      if (from != null) {
        _fromDate[r] = from;
        _fromTime[r] = TimeOfDay.fromDateTime(from);
      }
      if (to != null) {
        _toDate[r] = to;
        _toTime[r] = TimeOfDay.fromDateTime(to);
      }
    }

    seed(_Range.created, f.createdFrom, f.createdTo);
    seed(_Range.paid, f.paidFrom, f.paidTo);
    seed(_Range.confirmed, f.confirmedFrom, f.confirmedTo);
  }

  @override
  void dispose() {
    _amountFromCtrl.dispose();
    _amountToCtrl.dispose();
    super.dispose();
  }

  static String _numText(num? value) =>
      value == null ? '' : Formatters.formatAmount('$value');

  num? _parseNum(String text) => num.tryParse(text.replaceAll(' ', '').trim());

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

  // ── Sana / vaqt ───────────────────────────────────────────────────────────

  Future<void> _pickDate(_Range r, bool from) async {
    final now = DateTime.now();
    final initial = (from ? _fromDate[r] : _toDate[r]) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _fromDate[r] = picked : _toDate[r] = picked);
    }
  }

  Future<void> _pickTime(_Range r, bool from) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (from ? _fromTime[r] : _toTime[r]) ??
          const TimeOfDay(hour: 0, minute: 0),
      // Faqat qo'lda kiritish — soat (clock) rejimi va unga o'tkazgich yo'q.
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (ctx, child) => _themedPicker(ctx, child!),
    );
    if (picked != null) {
      setState(() => from ? _fromTime[r] = picked : _toTime[r] = picked);
    }
  }

  // ── Tozalash / Shakllantirish ─────────────────────────────────────────────

  void _reset() {
    setState(() {
      _type = null;
      _categoryId = null;
      _projectId = null;
      _amountFromCtrl.clear();
      _amountToCtrl.clear();
      for (final r in _Range.values) {
        _fromDate[r] = null;
        _fromTime[r] = null;
        _toDate[r] = null;
        _toTime[r] = null;
      }
      _open = _Field.none;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    DateTime? combine(DateTime? d, TimeOfDay? t) => d == null
        ? null
        : DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
    DateTime? from(_Range r) => combine(_fromDate[r], _fromTime[r]);
    DateTime? to(_Range r) => combine(_toDate[r], _toTime[r]);

    Navigator.of(context).pop(
      ExpenseRequestFilter(
        type: _type,
        categoryId: _categoryId,
        projectId: _projectId,
        amountFrom: _parseNum(_amountFromCtrl.text),
        amountTo: _parseNum(_amountToCtrl.text),
        createdFrom: from(_Range.created),
        createdTo: to(_Range.created),
        paidFrom: from(_Range.paid),
        paidTo: to(_Range.paid),
        confirmedFrom: from(_Range.confirmed),
        confirmedTo: to(_Range.confirmed),
        search: widget.initial.search,
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
          child:
              BlocBuilder<ExpenseRequestOptionsBloc, ExpenseRequestOptionsState>(
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
                              label: l10n.ledgerFilterExpenseType,
                              value: _type == null
                                  ? null
                                  : _typeLabel(_type!, l10n),
                              placeholder: l10n.ledgerFilterExpenseTypeHint,
                              link: _links[_Field.type],
                              onTap: () => _toggle(_Field.type),
                              onClear: () => setState(() => _type = null),
                            ),
                            AppFilterFieldBox(
                              label: l10n.expenseRequestFilterCategory,
                              value: _optionTitle(
                                state.options?.categories,
                                _categoryId,
                              ),
                              placeholder:
                                  l10n.expenseRequestFilterCategoryHint,
                              link: _links[_Field.category],
                              onTap: () => _toggle(_Field.category),
                              onClear: () =>
                                  setState(() => _categoryId = null),
                            ),
                            AppFilterFieldBox(
                              label: l10n.expenseReportProject,
                              value: _optionTitle(
                                state.options?.projects,
                                _projectId,
                              ),
                              placeholder: l10n.expenseReportProjectHint,
                              link: _links[_Field.project],
                              onTap: () => _toggle(_Field.project),
                              onClear: () => setState(() => _projectId = null),
                            ),
                            _AmountRange(
                              label: l10n.expenseRequestFilterAmount,
                              fromCtrl: _amountFromCtrl,
                              toCtrl: _amountToCtrl,
                            ),
                            _DateTimeRange(
                              label: l10n.payrollFilterCreatedRange,
                              range: _Range.created,
                              state: this,
                            ),
                            _DateTimeRange(
                              label: l10n.expenseRequestFilterPaidRange,
                              range: _Range.paid,
                              state: this,
                            ),
                            _DateTimeRange(
                              label: l10n.expenseRequestFilterConfirmedRange,
                              range: _Range.confirmed,
                              state: this,
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

  String? _optionTitle(List<ExpenseFilterOption>? options, int? id) {
    if (options == null || id == null) return null;
    for (final o in options) {
      if (o.id == id) return o.title;
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
    final options = context.read<ExpenseRequestOptionsBloc>().state.options;

    switch (_open) {
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
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final o in options?.categories ?? const <ExpenseFilterOption>[])
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: o.id == _categoryId,
                onTap: () => _pick(() => _categoryId = o.id),
                child: _labelRow(o.title),
              ),
          ],
        );
      case _Field.project:
        return AppFilterDropdownBox(
          emptyText: l10n.statEmpty,
          children: [
            for (final o in options?.projects ?? const <ExpenseFilterOption>[])
              AppFilterDropdownItem(
                verticalPadding: 6,
                selected: o.id == _projectId,
                onTap: () => _pick(() => _projectId = o.id),
                child: _labelRow(o.title),
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

String _typeLabel(ExpenseType t, AppLocalizations l10n) => switch (t) {
  ExpenseType.withdrawal => l10n.expenseReportTypeWithdrawal,
  ExpenseType.company => l10n.expenseReportTypeCompany,
  ExpenseType.other => l10n.expenseReportTypeOther,
  ExpenseType.unknown => '',
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

// ── Sana-vaqt oralig'i (dan/gacha, sana + qo'lda kiritiladigan vaqt) ───────

class _DateTimeRange extends StatelessWidget {
  const _DateTimeRange({
    required this.label,
    required this.range,
    required this.state,
  });

  final String label;
  final _Range range;
  final _ExpenseRequestsFilterViewState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Widget row(bool from) => Row(
      children: [
        Expanded(
          child: AppFilterPickerBox(
            value: _fmtDate(from ? state._fromDate[range] : state._toDate[range]),
            placeholder: l10n.taskFilterDateHint,
            icon: Assets.icons.icCalendar,
            onTap: () => state._pickDate(range, from),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: AppFilterPickerBox(
            value: _fmtTime(from ? state._fromTime[range] : state._toTime[range]),
            placeholder: '00:00',
            icon: Assets.icons.icTuilconTime,
            onTap: () => state._pickTime(range, from),
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
        row(true),
        row(false),
      ],
    );
  }
}

// ── Summa oralig'i (dan/gacha, ming ajratkichi bilan) ──────────────────────

class _AmountRange extends StatelessWidget {
  const _AmountRange({
    required this.label,
    required this.fromCtrl,
    required this.toCtrl,
  });

  final String label;
  final TextEditingController fromCtrl;
  final TextEditingController toCtrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.h,
      children: [
        AppFilterFieldLabel(label),
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
