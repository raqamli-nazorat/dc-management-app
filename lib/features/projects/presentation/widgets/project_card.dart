import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/project.dart';

String formatProjectDateRange(DateTime? start, DateTime? end) {
  String two(int value) => value.toString().padLeft(2, '0');
  String date(DateTime value) =>
      '${two(value.day)}.${two(value.month)}.${value.year}';
  if (start == null && end == null) return '';
  if (start == null) return date(end!);
  if (end == null) return date(start);
  return '${date(start)} - ${date(end)}';
}

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, this.onDelete});

  final Project project;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final manager = project.manager ?? project.createdBy;
    final initials = manager?.initials.isNotEmpty == true
        ? manager!.initials
        : project.prefix;
    final period = formatProjectDateRange(project.createdAt, project.deadline);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      project.title
                          .s(13.sp)
                          .w(800)
                          .h(20 / 13)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (project.prefix.isNotEmpty)
                        project.prefix
                            .s(13.sp)
                            .w(500)
                            .h(20 / 13)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _StatusPill(status: project.status),
              ],
            ),
            if (project.description.isNotEmpty) ...[
              SizedBox(height: 2.h),
              project.description
                  .s(11.sp)
                  .w(500)
                  .h(16 / 11)
                  .c(colors.textSub)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            if (period.isNotEmpty) ...[
              SizedBox(height: 12.h),
              Row(
                children: [
                  Assets.icons.icCalendar.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: period
                        .s(13.sp)
                        .w(500)
                        .h(20 / 13)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
            SizedBox(height: 8.h),
            Row(
              children: [
                _InitialAvatar(initials: initials),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (manager?.username.isNotEmpty == true)
                        manager!.username
                            .s(13.sp)
                            .w(500)
                            .h(20 / 13)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      if (manager?.position.isNotEmpty == true)
                        manager!.position
                            .s(11.sp)
                            .w(500)
                            .h(16 / 11)
                            .c(colors.textSoft)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                _MoreMenu(onDelete: onDelete),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(color: colors.iconSoft, shape: BoxShape.circle),
      child: SizedBox(
        width: 24.w,
        height: 24.w,
        child: Center(
          child: initials
              .toUpperCase()
              .s(11.sp)
              .w(800)
              .h(16 / 11)
              .c(colors.textWhite)
              .a(TextAlign.center),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ProjectStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final label = projectStatusLabel(status, AppLocalizations.of(context));
    if (label.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        child: label
            .s(11.sp)
            .w(800)
            .h(16 / 11)
            .c(colors.textWhite)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

enum _ProjectMenuAction { delete }

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<_ProjectMenuAction>(
      tooltip: '',
      padding: EdgeInsets.zero,
      color: colors.backgroundBase,
      elevation: 0,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colors.strokeSub, width: 1.w),
      ),
      onSelected: (_) => onDelete?.call(),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: _ProjectMenuAction.delete,
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            children: [
              Assets.icons.icTrash.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.errorStrong,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: l10n.taskMenuDelete
                    .s(13.sp)
                    .w(500)
                    .c(colors.errorStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
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

String projectStatusLabel(ProjectStatus status, AppLocalizations l10n) =>
    switch (status) {
      ProjectStatus.planning => l10n.projectStatusPlanning,
      ProjectStatus.active => l10n.projectStatusActive,
      ProjectStatus.overdue => l10n.projectStatusOverdue,
      ProjectStatus.completed => l10n.projectStatusCompleted,
      ProjectStatus.cancelled => l10n.projectStatusCancelled,
      ProjectStatus.unknown => '',
    };
