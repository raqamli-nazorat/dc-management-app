import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/access/nav_permissions.dart';
import '../../../../core/access/role_type.dart';
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
  const ProjectCard({
    super.key,
    required this.project,
    required this.role,
    this.onDetails,
    this.onEdit,
    this.onDelete,
  });

  final Project project;
  final RoleType role;
  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
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
                _MoreMenu(
                  canManage: NavPermissions.canManageProject(role),
                  onDetails: onDetails,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
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

enum _ProjectMenuAction { edit, details, delete }

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({
    required this.canManage,
    this.onDetails,
    this.onEdit,
    this.onDelete,
  });

  final bool canManage;
  final VoidCallback? onDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  Future<void> _onSelected(
    BuildContext context,
    _ProjectMenuAction action,
  ) async {
    switch (action) {
      case _ProjectMenuAction.edit:
        onEdit?.call();
      case _ProjectMenuAction.details:
        onDetails?.call();
      case _ProjectMenuAction.delete:
        final confirmed = await showProjectDeleteDialog(context);
        if (confirmed == true) onDelete?.call();
    }
  }

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
      constraints: BoxConstraints(minWidth: 180.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: colors.strokeSub, width: 1.w),
      ),
      onSelected: (action) => _onSelected(context, action),
      itemBuilder: (_) => [
        if (canManage)
          PopupMenuItem(
            value: _ProjectMenuAction.edit,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _ProjectMenuRow(
              icon: Assets.icons.icSettingsLarge,
              label: l10n.projectMenuEdit,
              color: colors.textStrong,
            ),
          ),
        PopupMenuItem(
          value: _ProjectMenuAction.details,
          height: 40.h,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: _ProjectMenuRow(
            icon: Assets.icons.icAlertCircle,
            label: l10n.projectMenuDetails,
            color: colors.textStrong,
          ),
        ),
        if (canManage)
          PopupMenuItem(
            value: _ProjectMenuAction.delete,
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: _ProjectMenuRow(
              icon: Assets.icons.icTrash,
              label: l10n.projectMenuDelete,
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

class _ProjectMenuRow extends StatelessWidget {
  const _ProjectMenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final SvgGenImage icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
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

Future<bool?> showProjectDeleteDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: colors.backgroundBase,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: const _ProjectDeleteDialog(),
    ),
  );
}

class _ProjectDeleteDialog extends StatelessWidget {
  const _ProjectDeleteDialog();

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
                l10n.projectDeleteTitle
                    .s(19.sp)
                    .w(800)
                    .h(28 / 19)
                    .c(colors.textStrong)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                l10n.projectDeleteSubtitle
                    .s(15.sp)
                    .w(500)
                    .h(24 / 15)
                    .c(colors.textSub)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
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
                              l10n.projectDeleteCancel
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
                                  child: l10n.projectMenuDelete
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

String projectStatusLabel(ProjectStatus status, AppLocalizations l10n) =>
    switch (status) {
      ProjectStatus.planning => l10n.projectStatusPlanning,
      ProjectStatus.active => l10n.projectStatusActive,
      ProjectStatus.overdue => l10n.projectStatusOverdue,
      ProjectStatus.completed => l10n.projectStatusCompleted,
      ProjectStatus.cancelled => l10n.projectStatusCancelled,
      ProjectStatus.unknown => '',
    };
