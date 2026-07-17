import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/entities/ledger_filter.dart';
import '../widgets/transaction_type_label.dart';

/// Moliya tarixini filtrlash sahifasi (`Routes.ledgerFilter`). "Xarajat turi"
/// dropdowni (Chiqim/Kirim = `transaction_type`) + sana oralig'i
/// (`created_at`) + miqdor oralig'i (`amount`). "Shakllantirish" bosilganda
/// [LedgerFilter] `pop` orqali qaytariladi; qidiruv matni saqlanadi.
class LedgerFilterPage extends StatefulWidget {
  const LedgerFilterPage({required this.initial, super.key});

  final LedgerFilter initial;

  @override
  State<LedgerFilterPage> createState() => _LedgerFilterPageState();
}

class _LedgerFilterPageState extends State<LedgerFilterPage> {
  final _portalCtrl = OverlayPortalController();
  final _typeLink = LayerLink();
  bool _typeOpen = false;

  TransactionType? _type;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  late final _amountFromCtrl = TextEditingController();
  late final _amountToCtrl = TextEditingController();

  static const _types = [TransactionType.debit, TransactionType.credit];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _type = f.transactionType;
    _dateFrom = f.dateFrom;
    _dateTo = f.dateTo;
    _amountFromCtrl.text = _numText(f.amountFrom);
    _amountToCtrl.text = _numText(f.amountTo);
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

  void _toggleType() {
    FocusScope.of(context).unfocus();
    setState(() => _typeOpen = !_typeOpen);
    _typeOpen ? _portalCtrl.show() : _portalCtrl.hide();
  }

  void _closeType() {
    setState(() => _typeOpen = false);
    _portalCtrl.hide();
  }

  void _pickType(TransactionType? value) {
    setState(() {
      _type = value;
      _typeOpen = false;
    });
    _portalCtrl.hide();
  }

  Future<void> _pickDate(bool from) async {
    final now = DateTime.now();
    final initial = (from ? _dateFrom : _dateTo) ?? now;
    final picked = await showAppDatePicker(
      context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => from ? _dateFrom = picked : _dateTo = picked);
    }
  }

  void _reset() {
    setState(() {
      _type = null;
      _dateFrom = null;
      _dateTo = null;
      _amountFromCtrl.clear();
      _amountToCtrl.clear();
      _typeOpen = false;
    });
    _portalCtrl.hide();
  }

  void _apply() {
    Navigator.of(context).pop(
      LedgerFilter(
        transactionType: _type,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        amountFrom: _parseNum(_amountFromCtrl.text),
        amountTo: _parseNum(_amountToCtrl.text),
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
                        label: l10n.ledgerFilterExpenseType,
                        value: _type == null
                            ? null
                            : transactionTypeLabel(_type!, l10n),
                        placeholder: l10n.ledgerFilterExpenseTypeHint,
                        link: _typeLink,
                        onTap: _toggleType,
                        onClear: () => setState(() => _type = null),
                      ),
                      _DateRange(
                        label: l10n.ledgerFilterDateRange,
                        from: _fmtDate(_dateFrom),
                        to: _fmtDate(_dateTo),
                        onFrom: () => _pickDate(true),
                        onTo: () => _pickDate(false),
                      ),
                      _AmountRange(
                        label: l10n.ledgerFilterAmount,
                        fromCtrl: _amountFromCtrl,
                        toCtrl: _amountToCtrl,
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

  Widget _buildOverlay(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final width = MediaQuery.sizeOf(context).width - 40.w;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeType,
          ),
        ),
        CompositedTransformFollower(
          link: _typeLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomLeft,
          followerAnchor: Alignment.topLeft,
          offset: Offset(0, 8.h),
          child: SizedBox(
            width: width,
            child: AppFilterDropdownBox(
              emptyText: l10n.statEmpty,
              children: [
                for (final t in _types)
                  AppFilterDropdownItem(
                    verticalPadding: 6,
                    selected: t == _type,
                    onTap: () => _pickType(t),
                    child: transactionTypeLabel(t, l10n)
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

// ── Miqdor oralig'i (dan/gacha) ────────────────────────────────────────────

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
