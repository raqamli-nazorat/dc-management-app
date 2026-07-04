import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/util/app_options.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';

/// "Dizayn mavzusi" (yorug'lik/qorong'i rejim) tanlash varag'ini ochadi.
///
/// [NotificationDetailSheet]dagi `showModalBottomSheet` o'rash naqshini
/// ko'zguga oladi (bu dizaynda yuqori burchaklar 20r).
Future<void> showThemeSwitchSheet(BuildContext context) {
  final colors = AppColors.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: colors.backgroundBase,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => const _ThemeSwitchSheet(),
  );
}

class _ThemeSwitchSheet extends StatelessWidget {
  const _ThemeSwitchSheet();

  /// Tanlangan mavzuni ilova holatiga va xotiraga saqlaydi, so'ng varaqni
  /// yopadi.
  void _selectTheme(BuildContext context, ThemeMode mode) {
    final current = AppOptions.of(context);
    AppOptions.update(context, current.copyWith(themeMode: mode));

    final storage = getIt<StorageService>();
    storage.setString(
      StorageKeys.themeMode,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final themeMode = AppOptions.of(context).themeMode;
    final isDarkActive = themeMode == ThemeMode.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.strokeSub,
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: SizedBox(width: 24.w, height: 3.h),
              ),
            ),
            SizedBox(height: 16.h),
            l10n.profileThemeSheetTitle.s(19.sp).w(800).c(colors.textStrong),
            SizedBox(height: 2.h),
            l10n.profileThemeSheetSubtitle.s(13.sp).w(500).c(colors.textSub),
            SizedBox(height: 16.h),
            _ThemeOptionRow(
              icon: Assets.icons.icSun,
              label: l10n.profileThemeLight,
              selected: !isDarkActive,
              onTap: () => _selectTheme(context, ThemeMode.light),
            ),
            SizedBox(height: 8.h),
            _ThemeOptionRow(
              icon: Assets.icons.icMoon,
              label: l10n.profileThemeDark,
              selected: isDarkActive,
              onTap: () => _selectTheme(context, ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bitta tanlanadigan mavzu qatori — leading ikonka + yozuv, faol bo'lsa
/// fon + o'ng tomonda checkmark ikonkasi bilan.
class _ThemeOptionRow extends StatelessWidget {
  const _ThemeOptionRow({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.backgroundElevation1Alt : Colors.transparent,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              icon.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: label
                    .s(16.sp)
                    .w(400)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              if (selected) ...[
                SizedBox(width: 8.w),
                Assets.icons.icCheckmarkCircle.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter:
                      ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
