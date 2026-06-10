import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';

/// Rol tanlash kartasi (Figma: elevation-1-alt fon, 16 radius, 32/20 padding).
/// Ikonka markazlashgan `Assets` SVG'idan, mavzuga moslashadi.
class RoleTile extends StatelessWidget {
  const RoleTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(16.r);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: radius,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.svg(
                  width: 28.r,
                  height: 28.r,
                  colorFilter: ColorFilter.mode(
                    colors.iconStrong,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: label
                      .s(20.sp)
                      .w(800)
                      .c(colors.textStrong)
                      .h(24 / 20)
                      .a(TextAlign.center)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
