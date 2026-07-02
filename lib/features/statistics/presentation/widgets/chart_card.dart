import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';

/// Grafik kartasi — sarlavha + tana. Bosh sahifadagi barcha grafiklar shu
/// konteynerdan foydalanadi (bir xil fon, radius, padding).
class ChartCard extends StatelessWidget {
  const ChartCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardSurface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            title
                .s(16.sp)
                .w(700)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 16.h),
            child,
          ],
        ),
      ),
    );
  }
}
