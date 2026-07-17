import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../domain/entities/app_user.dart';

/// Bitta foydalanuvchi kartasi — "Foydalanuvchilar" tabi ro'yxati (Figma card,
/// dizayndagi checkbox ataylab yo'q — xato deb tasdiqlangan).
class UserCard extends StatelessWidget {
  const UserCard({required this.user, this.onTap, super.key});

  final AppUser user;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final roles = user.roles
        .map((r) => RolePresentation.of(l10n, r).label)
        .join(', ');

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.h,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TuiAvatar(
                    initial: user.username,
                    avatarUrl: user.avatar,
                    size: 40,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.h,
                      children: [
                        _LabeledValue(
                          label: l10n.userFullNameLabel,
                          value: user.username,
                        ),
                        _LabeledValue(
                          label: l10n.userPositionLabel,
                          value: user.positionName,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _LabeledValue(label: l10n.userRoleLabel, value: roles),
              _LabeledValue(
                label: l10n.userSalaryLabel,
                value: Formatters.formatAmountComma(user.fixedSalary),
              ),
              _LabeledValue(
                label: l10n.userBalanceLabel,
                value: Formatters.formatAmountComma(user.balance),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Yorliq: **Qiymat**" qatori — yorliq kulrang, qiymat qalin.
class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

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
