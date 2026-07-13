import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_delete_dialog.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/meeting.dart';

/// Yig‘ilish sanasini `dd.MM.yyyy HH:mm` ko‘rinishida formatlaydi.
String formatMeetingDate(DateTime? date) {
  if (date == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// Yig‘ilishlar ro‘yxatidagi bitta karta (Figma: elevation-1 fon, 16 radius).
class MeetingCard extends StatelessWidget {
  const MeetingCard({
    super.key,
    required this.meeting,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final Meeting meeting;
  final VoidCallback? onTap;

  /// "Tahrirlash" tanlanganda (menyudan) — tahrirlash formasini ochadi.
  final VoidCallback? onEdit;

  /// "O'chirish" tasdiqlangandan so'ng chaqiriladi.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final participantName = meeting.participantName;
    final participantPosition = meeting.participantPosition;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        meeting.title
                            .s(13.sp)
                            .w(800)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        if (meeting.projectName.isNotEmpty)
                          meeting.projectName
                              .s(13.sp)
                              .w(500)
                              .c(colors.textStrong)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _AttendanceBadge(checked: meeting.isCompleted),
                ],
              ),
              if (meeting.uid.isNotEmpty) ...[
                SizedBox(height: 2.h),
                'UID:${meeting.uid}'
                    .s(11.sp)
                    .w(500)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
              SizedBox(height: 12.h),
              Row(
                children: [
                  Assets.icons.icCalendar.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: formatMeetingDate(meeting.startDate)
                        .s(13.sp)
                        .w(500)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  TuiAvatar(
                    initial: participantName,
                    avatarUrl: meeting.participantAvatar,
                    size: 24,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (participantName.isEmpty ? '—' : participantName)
                            .s(13.sp)
                            .w(500)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        if (participantPosition.isNotEmpty)
                          participantPosition
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
                  SizedBox(width: 8.w),
                  _MoreMenu(onEdit: onEdit, onDelete: onDelete),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MeetingMenuAction { edit, delete }

/// Karta ⋮ tugmasi — "Tahrirlash / O'chirish" menyusi (Figma: tui-dropdown,
/// background-base fon, stroke-sub chegara, 12 radius; vazifa/loyiha
/// kartalari bilan bir xil uslub).
class _MoreMenu extends StatelessWidget {
  const _MoreMenu({this.onEdit, this.onDelete});

  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Future<void> _onSelected(
    BuildContext context,
    _MeetingMenuAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    switch (action) {
      case _MeetingMenuAction.edit:
        onEdit?.call();
      case _MeetingMenuAction.delete:
        final confirmed = await showAppDeleteDialog(
          context,
          title: l10n.meetingDeleteTitle,
          subtitle: l10n.meetingDeleteSubtitle,
        );
        if (confirmed == true) onDelete?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<_MeetingMenuAction>(
      tooltip: '',
      padding: EdgeInsets.zero,
      color: colors.backgroundBase,
      elevation: 0,
      position: PopupMenuPosition.under,
      constraints: BoxConstraints(minWidth: 180.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colors.strokeSub, width: 1.w),
      ),
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _MeetingMenuAction.edit,
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: _MenuRow(
            icon: Assets.icons.icSettingsLarge,
            label: l10n.projectMenuEdit,
            color: colors.textStrong,
          ),
        ),
        PopupMenuItem(
          value: _MeetingMenuAction.delete,
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: _MenuRow(
            icon: Assets.icons.icTrash,
            label: l10n.taskMenuDelete,
            color: colors.errorStrong,
          ),
        ),
      ],
      child: Assets.icons.icMoreVertical.svg(
        width: 24.w,
        height: 24.w,
        colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
      ),
    );
  }
}

/// Menyu qatori: ikonka + yozuv (yozuv rangi = ikonka rangi).
class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final SvgGenImage icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon.svg(
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: label
              .s(13.sp)
              .w(500)
              .c(color)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Qatnashuv nishoni: yashil check (qatnashdi) / qizil minus (qatnashmadi).
/// `ic_check` — tayyor kompozit nishon (yashil kvadrat + oq belgi), shu bois
/// rang filtri qo‘llanmaydi.
class _AttendanceBadge extends StatelessWidget {
  const _AttendanceBadge({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (checked) {
      return Assets.icons.icCheck.svg(width: 24.w, height: 24.w);
    }

    // Qatnashmadi — qizil yumaloq kvadrat + oq minus.
    return SizedBox(
      width: 24.w,
      height: 24.w,
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.errorSub,
            borderRadius: BorderRadius.circular(5.r),
          ),
          child: SizedBox(
            width: 22.w,
            height: 22.w,
            child: Center(
              child: SizedBox(
                width: 14.w,
                height: 2.4.h,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: colors.iconWhite),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
