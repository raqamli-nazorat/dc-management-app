import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/change_password_dialog.dart';

/// Xavfsizlik sahifasi — profil sozlamalaridagi "Xavfsizlik" qatoridan
/// push qilinadi. Hozircha bitta amal: parolni o'zgartirish (dialog ochadi).
/// Vizual naqsh profil sahifasidagi `_SettingsRow` bilan bir xil.
class SecurityPage extends StatelessWidget {
  const SecurityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _SecurityAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SecurityRow(
                      icon: Assets.icons.icLock,
                      label: l10n.securityChangePassword,
                      onTap: () => showChangePasswordDialog(context),
                    ),
                    SizedBox(height: 12.h),
                    _SecurityInfoRow(
                      icon: Assets.icons.icAutoLock,
                      label: l10n.securityAutoLock,
                      value: l10n.securityAutoLockValue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar: orqaga tugmasi + markazlashgan sarlavha (`profile_page`dagi
/// `_ProfileAppBar` naqshi bilan bir xil).
class _SecurityAppBar extends StatelessWidget {
  const _SecurityAppBar();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 24.w,
                height: 24.w,
                colorFilter:
                    ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: l10n.profileSecurity
                  .s(17.sp)
                  .w(800)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          SizedBox(width: 32.w),
        ],
      ),
    );
  }
}

/// Xavfsizlik sozlamalari qatori — leading ikonka + yozuv. Figma dizaynida
/// bu ro'yxatda o'ng "chevron" yo'q (`_SettingsRow`dan farqli).
class _SecurityRow extends StatelessWidget {
  const _SecurityRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              icon.svg(
                width: 20.w,
                height: 20.w,
                colorFilter:
                    ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: label
                    .s(15.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Faqat ma'lumot ko'rsatuvchi qator (harakat yo'q) — masalan "Avtomatik
/// qulflash: 3 daqiqa". Qiymat `colors.textAccent` bilan, o'ng tomonda.
class _SecurityInfoRow extends StatelessWidget {
  const _SecurityInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final SvgGenImage icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            icon.svg(
              width: 20.w,
              height: 20.w,
              colorFilter:
                  ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: label
                  .s(15.sp)
                  .w(500)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 8.w),
            value.s(13.sp).w(800).c(colors.textAccent),
          ],
        ),
      ),
    );
  }
}
