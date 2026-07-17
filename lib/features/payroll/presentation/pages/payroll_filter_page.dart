import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll_filter.dart';

/// Ish haqini filtrlash sahifasi (`Routes.payrollFilter`). Oy (dropdown) +
/// sana oralig'i (`month__gte/lte`) + jami miqdor oralig'i + jarima toggle
/// (ochilsa jarima oralig'i). "Qidirish" bosilganda [PayrollFilter] `pop`
/// orqali qaytariladi; qidiruv matni saqlanadi.
class PayrollFilterPage extends StatefulWidget {
  const PayrollFilterPage({required this.initial, super.key});

  final PayrollFilter initial;

  @override
  State<PayrollFilterPage> createState() => _PayrollFilterPageState();
}

class _PayrollFilterPageState extends State<PayrollFilterPage> {
  final _portalCtrl = OverlayPortalController();
  final _monthLink = LayerLink();
  bool _monthOpen = false;

  int? _month; // 1..12
  DateTime? _createdFrom;
  DateTime? _createdTo;
  bool _penaltyOn = false;
  late final _totalFromCtrl = TextEditingController();
  late final _totalToCtrl = TextEditingController();
  late final _penaltyFromCtrl = TextEditingController();
  late final _penaltyToCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _month = f.month?.month;
    _createdFrom = f.createdFrom;
    _createdTo = f.createdTo;
    _penaltyOn = f.penaltyEnabled;
    _totalFromCtrl.text = _numText(f.totalFrom);
    _totalToCtrl.text = _numText(f.totalTo);
    _penaltyFromCtrl.text = _numText(f.penaltyFrom);
    _penaltyToCtrl.text = _numText(f.penaltyTo);
  }

  @override
  void dispose() {
    _totalFromCtrl.dispose();
    _totalToCtrl.dispose();
    _penaltyFromCtrl.dispose();
    _penaltyToCtrl.dispose();
    super.dispose();
  }

  static String _numText(num? value) =>
      value == null ? '' : Formatters.formatAmount('$value');

  num? _parseNum(String text) => num.tryParse(text.replaceAll(' ', '').trim());

  void _toggleMonth() {
    FocusScope.of(context).unfocus();
    setState(() => _monthOpen = !_monthOpen);
    _monthOpen ? _portalCtrl.show() : _portalCtrl.hide();
  }

  void _closeMonth() {
    setState(() => _monthOpen = false);
    _portalCtrl.hide();
  }

  void _pickMonth(int m) {
    setState(() {
      _month = m;
      _monthOpen = false;
    });
    _portalCtrl.hide();
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final initial = (from ? _createdFrom : _createdTo) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _createdFrom = picked : _createdTo = picked);
    }
  }

  void _reset() {
    setState(() {
      _month = null;
      _createdFrom = null;
      _createdTo = null;
      _penaltyOn = false;
      _totalFromCtrl.clear();
      _totalToCtrl.clear();
      _penaltyFromCtrl.clear();
      _penaltyToCtrl.clear();
      _monthOpen = false;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    final now = DateTime.now();
    Navigator.of(context).pop(
      PayrollFilter(
        month: _month == null ? null : DateTime(now.year, _month!),
        createdFrom: _createdFrom,
        createdTo: _createdTo,
        totalFrom: _parseNum(_totalFromCtrl.text),
        totalTo: _parseNum(_totalToCtrl.text),
        penaltyEnabled: _penaltyOn,
        penaltyFrom: _penaltyOn ? _parseNum(_penaltyFromCtrl.text) : null,
        penaltyTo: _penaltyOn ? _parseNum(_penaltyToCtrl.text) : null,
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
                      AppFilterFieldBox(
                        label: l10n.payrollFilterMonth,
                        value: _month == null ? null : uzMonthName(_month!),
                        placeholder: l10n.payrollFilterMonthHint,
                        link: _monthLink,
                        onTap: _toggleMonth,
                        onClear: () => setState(() => _month = null),
                      ),
                      _DateRange(
                        label: l10n.payrollFilterCreatedRange,
                        from: _fmtDate(_createdFrom),
                        to: _fmtDate(_createdTo),
                        onFrom: () => _pickDate(true),
                        onTo: () => _pickDate(false),
                      ),
                      _AmountRange(
                        label: l10n.payrollFilterTotal,
                        fromCtrl: _totalFromCtrl,
                        toCtrl: _totalToCtrl,
                      ),
                      _PenaltyToggleRow(
                        label: l10n.payrollFilterPenalty,
                        value: _penaltyOn,
                        onChanged: (v) => setState(() => _penaltyOn = v),
                      ),
                      if (_penaltyOn)
                        _AmountRange(
                          fromCtrl: _penaltyFromCtrl,
                          toCtrl: _penaltyToCtrl,
                        ),
                    ],
                  ),
                ),
              ),
              AppFilterActionBar(
                resetLabel: l10n.taskFilterReset,
                applyLabel: l10n.payrollFilterApply,
                onReset: _reset,
                onApply: _apply,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 40.w;
    final l10n = AppLocalizations.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeMonth,
          ),
        ),
        CompositedTransformFollower(
          link: _monthLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: width,
            child: AppFilterDropdownBox(
              emptyText: l10n.statEmpty,
              children: [
                for (var m = 1; m <= 12; m++)
                  AppFilterDropdownItem(
                    verticalPadding: 6,
                    selected: m == _month,
                    onTap: () => _pickMonth(m),
                    child: uzMonthName(m)
                        .s(13.sp)
                        .w(700)
                        .c(AppColors.of(context).textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String _fmtDate(DateTime? d) {
  if (d == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(d.day)}.${two(d.month)}.${d.year}';
}

// ── Sana oralig'i (dan/gacha, faqat sana) ──────────────────────────────────

class _DateRange extends StatelessWidget {
  const _DateRange({
    required this.label,
    required this.from,
    required this.to,
    required this.onFrom,
    required this.onTo,
  });

  final String label;
  final String from;
  final String to;
  final VoidCallback onFrom;
  final VoidCallback onTo;

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
              child: AppFilterPickerBox(
                value: from,
                placeholder: l10n.taskFilterDateHint,
                icon: Assets.icons.icCalendar,
                onTap: onFrom,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: AppFilterPickerBox(
                value: to,
                placeholder: l10n.taskFilterDateHint,
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

// ── Miqdor oralig'i (dan/gacha, summa formatida) ───────────────────────────

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
      spacing: 8.h,
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

// ── Jarima toggle (yorliq + switch) ────────────────────────────────────────

class _PenaltyToggleRow extends StatelessWidget {
  const _PenaltyToggleRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(child: label.s(11.sp).w(500).h(16 / 11).c(colors.textSub)),
        SizedBox(
          height: 24.h,
          child: FittedBox(
            fit: BoxFit.fitHeight,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: colors.accentStrong,
              thumbColor: WidgetStateProperty.all(colors.textWhite),
            ),
          ),
        ),
      ],
    );
  }
}
