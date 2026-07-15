import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_date_picker.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll_report.dart';

/// Ish haqi hisoboti kartasi (Figma: 1826-379828 / 1845-470496).
class PayrollReportCard extends StatelessWidget {
  const PayrollReportCard({required this.report, super.key});
  final PayrollReport report;

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      report.user
                          .s(13.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (report.month != null)
                        '${uzMonthName(report.month!.month)} ${report.month!.year}'
                            .s(11.sp)
                            .w(500)
                            .c(colors.textSub),
                    ],
                  ),
                ),
              ],
            ),
            _PlainRow(
              label: l10n.payrollFixedSalary,
              value: _amount(report.fixedSalary),
            ),
            _PlainRow(
              label: l10n.payrollKpiBonus,
              value: _amount(report.kpiBonus),
            ),
            _PlainRow(
              label: l10n.payrollPenalty,
              value: report.penaltyAmount > 0
                  ? '-${_amount(report.penaltyAmount)}'
                  : _amount(report.penaltyAmount),
              valueColor: report.penaltyAmount > 0 ? colors.errorSub : null,
            ),
            _PlainRow(
              label: l10n.payrollTotal,
              value: _amount(report.totalAmount),
            ),
            if (report.status.isNotEmpty)
              _PlainRow(label: l10n.taskFilterStatus, value: report.status),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.w,
              children: [
                Expanded(
                  child: _AltBox(
                    label: l10n.payrollCreatedAt,
                    value: _fmt(report.createdAt),
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.expenseReportConfirmedAt,
                    value: _fmt(report.confirmedAt),
                  ),
                ),
              ],
            ),
            if (report.accountant.isNotEmpty)
              _AltBox(
                label: l10n.expenseReportAccountant,
                value: report.accountant,
              ),
          ],
        ),
      ),
    );
  }
}

String _amount(num value) =>
    Formatters.formatAmount(value.toStringAsFixed(2));

String _fmt(DateTime? date) =>
    date == null ? '' : DateFormat('dd.MM.yyyy HH:mm').format(date);

/// Fonsiz, justify-between yorliq/qiymat qatori.
class _PlainRow extends StatelessWidget {
  const _PlainRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;
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
              .c(valueColor ?? colors.textStrong)
              .a(TextAlign.right)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// `background-elevation-1-alt` foniga ega yorliq+qiymat bloki.
class _AltBox extends StatelessWidget {
  const _AltBox({required this.label, required this.value});
  final String label;
  final String value;
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
            SizedBox(
              width: double.infinity,
              child: label
                  .s(9.sp)
                  .w(500)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            value
                .s(11.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
