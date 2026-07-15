import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_report.dart';

/// Bitta xodim hisobot kartasi — `Xodim bo'yicha` ro'yxati (Figma card).
class UserReportCard extends StatelessWidget {
  const UserReportCard({required this.report, super.key});

  final UserReport report;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final breakdown = report.breakdown;

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TuiAvatar(initial: report.fullName, size: 24),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      report.fullName
                          .s(13.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      report.position
                          .s(11.sp)
                          .w(500)
                          .c(colors.textSoft)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4.h,
                  children: [
                    if (report.dateJoined != null)
                      _Chip(
                        DateFormat('dd.MM.yyyy').format(report.dateJoined!),
                      ),
                    if (report.phoneNumber.isNotEmpty)
                      _Chip(report.phoneNumber),
                  ],
                ),
              ],
            ),
            if (report.region.isNotEmpty || report.district.isNotEmpty)
              Row(
                spacing: 8.w,
                children: [
                  if (report.region.isNotEmpty) _Chip(report.region),
                  if (report.district.isNotEmpty) _Chip(report.district),
                ],
              ),
            _KeyValueRow(
              label: l10n.reportFixedSalary,
              value: Formatters.formatAmount(
                report.fixedSalary.toStringAsFixed(2),
              ),
            ),
            _KeyValueRow(
              label: l10n.reportBalance,
              value: Formatters.formatAmount(report.balance.toStringAsFixed(2)),
            ),
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: _StatBox(
                    label: '${l10n.reportProjects}: ${breakdown.projectsTotal}',
                    dotColor: colors.successPrimary,
                    valueLabel:
                        '${l10n.reportCompleted}: ${breakdown.projectsCompleted}',
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    label: '${l10n.reportTasksCount}: ${breakdown.tasksTotal}',
                    dotColor: colors.taskStatusTodo,
                    valueLabel: '${l10n.reportTodo}: ${breakdown.tasksTodo}',
                  ),
                ),
                Expanded(
                  child: _StatBox(
                    label: '${l10n.reportMeetings}: ${breakdown.meetingsTotal}',
                    dotColor: colors.successPrimary,
                    valueLabel:
                        '${l10n.reportCompleted}: ${breakdown.meetingsAttended}',
                  ),
                ),
              ],
            ),
            Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: _AmountBox(
                    label: l10n.reportExpenseRequests,
                    prefix: l10n.reportPaid,
                    amount: Formatters.formatAmount(
                      breakdown.expensesPaid.toStringAsFixed(2),
                    ),
                  ),
                ),
                Expanded(
                  child: _AmountBox(
                    label: l10n.reportPayroll,
                    prefix: l10n.reportKpiBonus,
                    amount: Formatters.formatAmount(
                      breakdown.payrollKpiBonus.toStringAsFixed(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: text
            .s(11.sp)
            .w(500)
            .c(colors.textStrong)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.s(11.sp).w(500).c(colors.textSub),
        value.s(11.sp).w(800).c(colors.textStrong),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.dotColor,
    required this.valueLabel,
  });

  final String label;
  final Color dotColor;
  final String valueLabel;

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
            label
                .s(11.sp)
                .w(500)
                .c(colors.textSub)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 8.w, height: 8.w),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: valueLabel
                      .s(9.sp)
                      .w(500)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountBox extends StatelessWidget {
  const _AmountBox({
    required this.label,
    required this.prefix,
    required this.amount,
  });

  final String label;
  final String prefix;
  final String amount;

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
            label
                .s(11.sp)
                .w(500)
                .c(colors.textSub)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            RichText(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$prefix: ',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.textStrong,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  TextSpan(
                    text: amount,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: colors.textStrong,
                      fontFamily: 'Manrope',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
