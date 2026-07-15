import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/expense_report.dart';

/// Xarajat so'rovi kartasi (Figma: node 1826-378449 / 1845-469990).
class ExpenseReportCard extends StatelessWidget {
  const ExpenseReportCard({required this.report, super.key});
  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSoft, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.h,
          children: [
            Row(
              children: [
                TuiAvatar(initial: report.user, size: 24),
                SizedBox(width: 8.w),
                Expanded(
                  child: report.user
                      .s(13.sp)
                      .w(500)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4.h,
              children: [
                if (report.project.isNotEmpty)
                  _AltBox(label: l10n.expenseReportProject, value: report.project),
                _AltBox(
                  label: l10n.expenseReportType,
                  value: _typeLabel(report.type, l10n),
                ),
                if (report.expenseCategory.isNotEmpty)
                  _AltBox(
                    label: l10n.expenseReportCategory,
                    value: report.expenseCategory,
                  ),
                if (report.reason.isNotEmpty)
                  _AltBox(label: l10n.expenseReportReason, value: report.reason),
              ],
            ),
            _PlainRow(
              label: l10n.taskFilterStatus,
              value: _statusLabel(report.status, l10n),
            ),
            _PlainRow(
              label: l10n.expenseReportPaymentMethod,
              value: _paymentLabel(report.paymentMethod, l10n),
            ),
            _PlainRow(
              label: l10n.expenseReportAmount,
              value: Formatters.formatAmount(report.amount.toStringAsFixed(2)),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.w,
              children: [
                Expanded(
                  child: _AltBox(
                    label: l10n.expenseReportCreatedAt,
                    value: _fmt(report.createdAt),
                    compact: true,
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.expenseReportPaidAt,
                    value: _fmt(report.paidAt),
                    compact: true,
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.expenseReportConfirmedAt,
                    value: _fmt(report.confirmedAt),
                    compact: true,
                  ),
                ),
              ],
            ),
            if (report.accountant.isNotEmpty)
              _AltBox(
                label: l10n.expenseReportAccountant,
                value: report.accountant,
              ),
            if (report.cancelledAt != null || report.cancelReason.isNotEmpty)
              _CancelledBox(report: report, l10n: l10n),
          ],
        ),
      ),
    );
  }
}

String _fmt(DateTime? date) =>
    date == null ? '' : DateFormat('dd.MM.yyyy HH:mm').format(date);

/// `background-elevation-1-alt` foniga ega yorliq+qiymat bloki.
class _AltBox extends StatelessWidget {
  const _AltBox({
    required this.label,
    required this.value,
    this.compact = false,
  });

  final String label;
  final String value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2.h,
          children: [
            label
                .s(9.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            value
                .s(compact ? 9.sp : 11.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(
                  maxLines: compact ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),
          ],
        ),
      ),
    );
  }
}

/// Fonsiz, justify-between yorliq/qiymat qatori (Holati/To'lov turi/Miqdor).
class _PlainRow extends StatelessWidget {
  const _PlainRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.s(11.sp).w(500).c(colors.textSub),
        Flexible(
          child: value
              .s(11.sp)
              .w(800)
              .c(colors.textStrong)
              .a(TextAlign.right)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _CancelledBox extends StatelessWidget {
  const _CancelledBox({required this.report, required this.l10n});
  final ExpenseReport report;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                l10n.expenseReportCancelledAt.s(9.sp).w(500).c(colors.textStrong),
                _fmt(report.cancelledAt).s(9.sp).w(500).c(colors.textStrong),
              ],
            ),
            if (report.cancelReason.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.w,
                children: [
                  l10n.expenseReportCancelReason
                      .s(9.sp)
                      .w(500)
                      .c(colors.textStrong),
                  Expanded(
                    child: report.cancelReason
                        .s(9.sp)
                        .w(500)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

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

String _paymentLabel(ExpensePaymentMethod value, AppLocalizations l10n) =>
    switch (value) {
      ExpensePaymentMethod.cash => l10n.expenseReportPaymentCash,
      ExpensePaymentMethod.card => l10n.expenseReportPaymentCard,
      ExpensePaymentMethod.unknown => '',
    };
