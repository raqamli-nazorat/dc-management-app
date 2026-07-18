import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/expense_report.dart';
import '../../domain/entities/expense_request.dart';

/// Bitta xarajat so'rovi kartasi — "Xarajat so'rovlari" ro'yxati (Figma:
/// node 1881-316875). O'ngdagi belgi `status == confirmed` holatini
/// ko'rsatadi (tasdiqlangan — yashil check).
class ExpenseRequestCard extends StatelessWidget {
  const ExpenseRequestCard({required this.request, super.key});

  final ExpenseRequest request;

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TuiAvatar(
              initial: request.userName,
              avatarUrl: request.avatar,
              size: 40,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.h,
                children: [
                  _Line(
                    label: l10n.userFullNameLabel,
                    value: request.userName,
                  ),
                  _Line(
                    label: l10n.expenseRequestProjectLabel,
                    value: request.projectName,
                  ),
                  _Line(
                    label: l10n.expenseRequestTypeLabel,
                    value: _typeLabel(request.type, l10n),
                  ),
                  _Line(
                    label: l10n.expenseRequestAmountLabel,
                    value: Formatters.formatAmountComma(request.amount),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _ConfirmBadge(
              confirmed: request.status == ExpenseStatus.confirmed,
            ),
          ],
        ),
      ),
    );
  }
}

String _typeLabel(ExpenseType type, AppLocalizations l10n) => switch (type) {
  ExpenseType.withdrawal => l10n.expenseReportTypeWithdrawal,
  ExpenseType.company => l10n.expenseReportTypeCompany,
  ExpenseType.other => l10n.expenseReportTypeOther,
  ExpenseType.unknown => '',
};

/// Tasdiqlangan — kompozit yashil check (`ic_check`, colorFilter'siz);
/// tasdiqlanmagan — bo'sh ramkali kvadrat.
class _ConfirmBadge extends StatelessWidget {
  const _ConfirmBadge({required this.confirmed});

  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (confirmed) {
      return Assets.icons.icCheck.svg(width: 24.w, height: 24.w);
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: SizedBox(width: 24.w, height: 24.w),
    );
  }
}

/// "Yorliq: **Qiymat**" qatori — yorliq kulrang, qiymat qalin.
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Text.rich(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.textSub,
              fontFamily: 'Manrope',
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colors.textStrong,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}
