import 'package:dc_management_app/config/routes/entity/routes.dart';
import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/extentions/text_extensions.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// "Loyihalar" tabi — Loyihalar / Vazifalar / Yig'ilishlar kartalari.
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            _NavTile(
              label: 'Loyihalar',
              image: Assets.images.projects,
              imageSize: 82.w,
            ),
            Row(
              spacing: 12,
              children: [
                Flexible(
                  child: _NavTile(
                    label: 'Vazifalar',
                    image: Assets.images.tasks,
                    imageSize: 72.w,
                    onTap: () => context.pushNamed(Routes.tasks.name),
                  ),
                ),
                Flexible(
                  child: _NavTile(
                    label: 'Yig’ilishlar',
                    image: Assets.images.meetings,
                    imageSize: 72.w,
                    onTap: () => context.pushNamed(Routes.meetings.name),
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

/// Kartaga bosiladigan navigatsiya bloki: chapda sarlavha, o'ngda illyustratsiya.
class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.image,
    required this.imageSize,
    this.onTap,
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
