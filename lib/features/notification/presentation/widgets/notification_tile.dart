import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../domain/entities/notification.dart';

/// Ro‘yxatdagi bitta bildirishnoma qatori (design: `ToastNotification`).
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final NotificationEntity notification;
  final VoidCallback onTap;

  /// Ost-yozuv oldidagi kategoriya ikonkasi (turiga qarab).
  SvgGenImage get _categoryIcon {
    final t = notification.type.toLowerCase();
    if (t.contains('fin') ||
        t.contains('salary') ||
        t.contains('pul') ||
        t.contains('expense') ||
        t.contains('moliya')) {
      return Assets.icons.icBriefcaseDollar;
    }
    return Assets.icons.icFolder;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final initial =
        notification.title.isNotEmpty ? notification.title : '?';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TuiAvatar(
              initial: initial,
              badge: notification.isRead
                  ? TuiAvatarBadge.read
                  : TuiAvatarBadge.unread,
              count: notification.isRead ? 0 : 1,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  notification.title
                      .s(15.sp)
                      .w(notification.isRead ? 600 : 700)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (notification.message.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 2.h),
                          child: _categoryIcon.svg(
                            width: 16.w,
                            height: 16.w,
                            colorFilter: ColorFilter.mode(
                              colors.iconSub,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: notification.message
                              .s(13.sp)
                              .w(500)
                              .c(colors.textSub)
                              .copyWith(
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
