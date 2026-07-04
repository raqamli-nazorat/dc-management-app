import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/task.dart';

/// `dd.MM.yyyy HH:mm` ko'rinishida sana.
String _formatDeadline(DateTime? date) {
  if (date == null) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year} '
      '${two(date.hour)}:${two(date.minute)}';
}

/// Rejalashtirilgan vaqt: "24h 12min" / "12min" / bo'sh.
String _formatEstimated(int? minutes) {
  if (minutes == null || minutes <= 0) return '';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}min';
  if (m == 0) return '${h}h';
  return '${h}h ${m}min';
}

/// Muddatgacha qolgan vaqt "HH:MM:SS" — o'tib ketgan/yo'q bo'lsa bo'sh.
///
// ponytail: build vaqtida bir marta hisoblanadi (tiklanmaydi). Har-soniya
// tiklash kerak bo'lsa — kartaga Timer qo'shiladi.
String _formatCountdown(DateTime? deadline) {
  if (deadline == null) return '';
  final diff = deadline.difference(DateTime.now());
  if (diff.isNegative) return '';
  String two(int v) => v.toString().padLeft(2, '0');
  final h = diff.inHours;
  final m = diff.inMinutes % 60;
  final s = diff.inSeconds % 60;
  return '${two(h)}:${two(m)}:${two(s)}';
}

/// Vazifalar ro'yxatidagi bitta karta (Figma: elevation-1 fon, 16 radius).
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task, this.onTap, this.onMore});

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final countdown = _formatCountdown(task.deadline);
    final estimated = _formatEstimated(task.estimatedMinutes);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colors.strokeSoft, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Sarlavha bloki: dot+uid, title, priority pill ────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _StatusDot(status: task.status),
                            SizedBox(width: 6.w),
                            if (task.uid.isNotEmpty)
                              task.uid
                                  .s(11.sp)
                                  .w(700)
                                  .c(colors.textStrong)
                                  .copyWith(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        task.title
                            .s(15.sp)
                            .w(800)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  _PriorityPill(priority: task.priority),
                ],
              ),
              SizedBox(height: 2.h),
              // ── Loyiha + tavsif ──────────────────────────────────────────
              if (task.projectInfo.isNotEmpty)
                task.projectInfo
                    .s(13.sp)
                    .w(700)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              if (task.description.isNotEmpty)
                task.description
                    .s(11.sp)
                    .w(700)
                    .c(colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              SizedBox(height: 8.h),
              // ── Meta qatori: sana, vaqt, orqa sanoq ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _MetaItem(
                          icon: Assets.icons.icCalendar,
                          text: _formatDeadline(task.deadline),
                        ),
                        if (estimated.isNotEmpty) ...[
                          SizedBox(width: 12.w),
                          _MetaItem(icon: Assets.icons.icSoon, text: estimated),
                        ],
                      ],
                    ),
                  ),
                  if (countdown.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    _CountdownChip(text: countdown),
                  ],
                ],
              ),
              SizedBox(height: 8.h),
              // ── Ijrochi qatori ───────────────────────────────────────────
              Row(
                children: [
                  TuiAvatar(initial: task.assigneeName, size: 24),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        (task.assigneeName.isEmpty ? '—' : task.assigneeName)
                            .s(13.sp)
                            .w(700)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        if (task.assigneePosition.isNotEmpty)
                          task.assigneePosition
                              .s(11.sp)
                              .w(700)
                              .c(colors.textSoft)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: onMore,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Assets.icons.icMoreVertical.svg(
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Holat nuqtasi (12×12 doira).
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final TaskStatus status;

  Color _color(AppColors colors) {
    switch (status) {
      case TaskStatus.todo:
        return colors.taskStatusTodo;
      case TaskStatus.inProgress:
        return colors.taskStatusInProgress;
      case TaskStatus.overdue:
        return colors.taskStatusOverdue;
      case TaskStatus.done:
        return colors.taskStatusDone;
      case TaskStatus.production:
        return colors.taskStatusProduction;
      case TaskStatus.checked:
        return colors.taskStatusChecked;
      case TaskStatus.rejected:
        return colors.taskStatusRejected;
      case TaskStatus.unknown:
        return colors.textSoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12.w,
      height: 12.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _color(AppColors.of(context)),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Muhimlik pill'i (px12 py4, radius 15, rangli fon + oq matn).
class _PriorityPill extends StatelessWidget {
  const _PriorityPill({required this.priority});

  final TaskPriority priority;

  (Color, String) _resolve(AppColors colors, AppLocalizations l10n) {
    switch (priority) {
      case TaskPriority.low:
        return (colors.taskPriorityLow, l10n.taskPriorityLow);
      case TaskPriority.medium:
        return (colors.taskPriorityMedium, l10n.taskPriorityMedium);
      case TaskPriority.high:
        return (colors.taskPriorityHigh, l10n.taskPriorityHigh);
      case TaskPriority.critical:
        return (colors.taskPriorityCritical, l10n.taskPriorityCritical);
      case TaskPriority.unknown:
        return (colors.textSoft, '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final (color, label) = _resolve(colors, AppLocalizations.of(context));
    if (label.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: label.s(11.sp).w(800).c(colors.textWhite),
      ),
    );
  }
}

/// Ikonka + matn juftligi (sana / vaqt).
class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});

  final SvgGenImage icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon.svg(
          width: 16.w,
          height: 16.w,
          colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: text
              .s(13.sp)
              .w(700)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

/// Orqa sanoq chipi (error-disabled fon + error-sub matn).
class _CountdownChip extends StatelessWidget {
  const _CountdownChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.errorDisabled,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: text.s(11.sp).w(800).c(colors.errorSub),
      ),
    );
  }
}
