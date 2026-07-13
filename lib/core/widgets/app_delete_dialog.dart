import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// O'chirishni tasdiqlash dialogi (Figma: 350 kenglik, 24 radius, grabber).
/// `true` — tasdiqlandi, `null`/`false` — bekor. Sarlavha/izoh chaqiruvchidan
/// keladi (vazifa/yig'ilish va h.k. uchun bitta komponent).
Future<bool?> showAppDeleteDialog(
  BuildContext context, {
  required String title,
  required String subtitle,
  String? confirmLabel,
}) {
  final colors = AppColors.of(context);
  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: colors.backgroundBase,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: _DeleteDialog(
        title: title,
        subtitle: subtitle,
        confirmLabel: confirmLabel,
      ),
    ),
  );
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({
    required this.title,
    required this.subtitle,
    this.confirmLabel,
  });

  final String title;
  final String subtitle;
  final String? confirmLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 8.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.strokeSoft,
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: SizedBox(width: 24.w, height: 3.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                title
                    .s(19.sp)
                    .w(800)
                    .h(28 / 19)
                    .c(colors.textStrong)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                subtitle
                    .s(15.sp)
                    .w(500)
                    .h(24 / 15)
                    .c(colors.textSub)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(false),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: SizedBox(
                          height: 52.h,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Assets.icons.icClose.svg(
                                width: 16.w,
                                height: 16.w,
                                colorFilter: ColorFilter.mode(
                                  colors.textStrong,
                                  BlendMode.srcIn,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              l10n.taskDeleteCancel
                                  .s(15.sp)
                                  .w(800)
                                  .h(24 / 15)
                                  .c(colors.textStrong)
                                  .copyWith(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(true),
                        borderRadius: BorderRadius.circular(16.r),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.errorStrong,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: SizedBox(
                            height: 52.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.icons.icTrash.svg(
                                  width: 16.w,
                                  height: 16.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.textWhite,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: (confirmLabel ?? l10n.taskMenuDelete)
                                      .s(15.sp)
                                      .w(800)
                                      .h(24 / 15)
                                      .c(colors.textWhite)
                                      .copyWith(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
