import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/notification.dart';

/// Bildirishnomani o‘qish uchun pastdan chiquvchi varaq (bottom sheet).
///
/// Ochilganda [NotificationDetailSheet.show] uni ko‘rsatadi; ochilishi
/// bildirishnomani o‘qilgan deb belgilash chaqiruvi bilan birga bo‘ladi
/// (chaqiruvchi tomonda).
class NotificationDetailSheet extends StatelessWidget {
  const NotificationDetailSheet({super.key, required this.notification});

  final NotificationEntity notification;

  static Future<void> show(
    BuildContext context,
    NotificationEntity notification,
  ) {
    final colors = AppColors.of(context);
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.backgroundBase,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => NotificationDetailSheet(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grabber
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.strokeStrong,
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: SizedBox(width: 40.w, height: 4.h),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TuiAvatar(
                  initial: notification.title,
                  badge: TuiAvatarBadge.read,
                  size: 40,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: notification.title
                      .s(17.sp)
                      .w(700)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (notification.message.isNotEmpty)
              notification.message
                  .s(14.sp)
                  .w(500)
                  .c(colors.textSub)
                  .h(1.4),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentSub,
                  foregroundColor: colors.textWhite,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: l10n.notificationClose.s(15.sp).w(600).c(colors.textWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
