import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// Har bir tab uchun vaqtinchalik "default UI" — sarlavha + "tez orada".
/// Keyingi bosqichlarda haqiqiy ekran bilan almashtiriladi.
class TabPlaceholder extends StatelessWidget {
  const TabPlaceholder({super.key, required this.title, required this.icon});

  final String title;
  final SvgGenImage icon;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon.svg(
              width: 40.w,
              height: 40.w,
              colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
            ),
            SizedBox(height: 12.h),
            title.s(18.sp).w(700).c(colors.textStrong),
            SizedBox(height: 4.h),
            l10n.comingSoon.s(13.sp).w(500).c(colors.textSub),
          ],
        ),
      ),
    );
  }
}
