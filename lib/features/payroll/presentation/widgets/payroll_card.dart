import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll.dart';

/// Bitta ish haqi kartasi — "Ish haqi" ro'yxati (Figma card). O'ngdagi belgi
/// `is_confirmed` holatini ko'rsatadi (tasdiqlangan — yashil check). Bosilганda
/// detail sahifasiga o'tadi.
class PayrollCard extends StatelessWidget {
  const PayrollCard({required this.payroll, this.onTap, super.key});

  final Payroll payroll;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
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
                initial: payroll.userName,
                avatarUrl: payroll.avatar,
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
                      value: payroll.userName,
                    ),
                    _Line(
                      label: l10n.payrollMonthLabel,
                      value: payroll.monthDisplay,
                    ),
                    _Line(
                      label: l10n.payrollKpiLabel,
                      value: Formatters.formatAmountComma(payroll.kpiBonus),
                    ),
                    _Line(
                      label: l10n.payrollTotalLabel,
                      value: Formatters.formatAmountComma(payroll.totalAmount),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _ConfirmBadge(confirmed: payroll.isConfirmed),
            ],
          ),
        ),
      ),
    );
  }
}

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
