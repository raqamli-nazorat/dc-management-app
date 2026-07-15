import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/meeting_attendance.dart';

/// Tashkilotchi uchun bitta qatnashmagan xodim kartasi: avatar + ism + sabab
/// va "Rad etish"/"Tasdiqlash" tugmalari. Detail sahifasi va sabab (reason)
/// sahifasining organizer rejimida birgalikda ishlatiladi.
///
/// ponytail: backend'da rad etish maydoni yo'q (faqat is_excused bool) —
/// [rejected] holati sessiya ichida lokal ko'rsatiladi; qayta yuklashda qator
/// yana "kutilmoqda" ko'rinishiga qaytadi. Doimiy holat uchun backend'ga
/// excuse_status (pending/approved/rejected) kerak.
class MeetingExcuseRow extends StatelessWidget {
  const MeetingExcuseRow({
    super.key,
    required this.row,
    required this.busy,
    required this.rejected,
    required this.onApprove,
    required this.onReject,
  });

  final MeetingAttendance row;

  /// Shu qator uchun so'rov ketmoqda (tugmalar bloklanadi, spinner).
  final bool busy;

  /// Shu sessiyada rad etilgan (lokal belgi).
  final bool rejected;

  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final hasReason = row.absenceReason.trim().isNotEmpty;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TuiAvatar(
                  initial: row.userName,
                  avatarUrl: row.userAvatar,
                  size: 24,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      row.userName
                          .s(13.sp)
                          .w(700)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (row.userPosition.isNotEmpty)
                        row.userPosition
                            .s(11.sp)
                            .w(500)
                            .c(colors.textSoft)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            (hasReason ? row.absenceReason : l10n.meetingExcuseNoReason)
                .s(13.sp)
                .w(500)
                .h(20 / 13)
                .c(hasReason ? colors.textSub : colors.textSoft)
                .copyWith(maxLines: 4, overflow: TextOverflow.ellipsis),
            SizedBox(height: 12.h),
            if (row.isExcused)
              l10n.meetingExcuseAccepted
                  .s(13.sp)
                  .w(700)
                  .c(colors.successStrong)
            else if (rejected)
              l10n.meetingExcuseRejected
                  .s(13.sp)
                  .w(700)
                  .c(colors.errorStrong)
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: l10n.meetingExcuseReject,
                      background: colors.backgroundElevation3,
                      foreground: hasReason
                          ? colors.errorStrong
                          : colors.textSoft,
                      busy: busy,
                      onTap: hasReason && !busy ? onReject : null,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _ActionButton(
                      label: l10n.meetingCloseConfirm,
                      background: hasReason
                          ? colors.accentStrong
                          : colors.backgroundElevation3,
                      foreground: hasReason
                          ? colors.textWhite
                          : colors.textSoft,
                      busy: busy,
                      onTap: hasReason && !busy ? onApprove : null,
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.busy,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
          height: 40.h,
          child: Center(
            child: busy
                ? SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: foreground,
                    ),
                  )
                : label.s(13.sp).w(800).c(foreground),
          ),
        ),
      ),
    );
  }
}
