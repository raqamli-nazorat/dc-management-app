import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/extentions/text_extensions.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Kartaga bosiladigan navigatsiya bloki: chapda sarlavha, o'ngda illyustratsiya.
class AppNavTile extends StatelessWidget {
  const AppNavTile({
    required this.label,
    required this.image,
    required this.imageSize,
    this.onTap,
    super.key,
  });

  final String label;
  final AssetGenImage image;
  final double imageSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: SizedBox(
        height: 92.h,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              spacing: 8.w,
              children: [
                Expanded(
                  child: label
                      .s(15.sp)
                      .w(800)
                      .c(colors.iconStrong)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                image.image(
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
