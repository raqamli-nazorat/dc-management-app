import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/project_report.dart';

/// Bitta loyiha hisobot kartasi — `Loyiha bo'yicha` ro'yxati (Figma card).
/// Xodimlar/Sinovchilar/Vazifalar bo'limlari ochilib-yopiladi.
class ProjectReportCard extends StatefulWidget {
  const ProjectReportCard({required this.report, super.key});

  final ProjectReport report;

  @override
  State<ProjectReportCard> createState() => _ProjectReportCardState();
}

class _ProjectReportCardState extends State<ProjectReportCard> {
  bool _employeesOpen = false;
  bool _testersOpen = false;
  bool _tasksOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final report = widget.report;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSoft, width: 1.w),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.h,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      report.title
                          .s(13.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (report.description.isNotEmpty)
                        report.description
                            .s(11.sp)
                            .w(500)
                            .c(colors.textSub)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                if (report.deadline != null)
                  _Chip(
                    DateFormat('dd.MM.yyyy HH:mm').format(report.deadline!),
                  ),
              ],
            ),
            _Chip(
              '${l10n.reportStatusLabel} ${_statusLabel(report.status, l10n)}',
            ),
            _KeyValueRow(
              label: l10n.reportManagerBonus,
              value: Formatters.formatAmount(
                report.projectPrice.toStringAsFixed(2),
              ),
            ),
            _InfoBox(label: l10n.reportAuthor, value: report.createdByName),
            _InfoBox(label: l10n.reportManager, value: report.managerName),
            _ExpandableBox(
              label: l10n.reportEmployeesLabel,
              value: report.employeesNames,
              open: _employeesOpen,
              onTap: () => setState(() => _employeesOpen = !_employeesOpen),
            ),
            _ExpandableBox(
              label: l10n.reportTestersLabel,
              value: report.testersNames,
              open: _testersOpen,
              onTap: () => setState(() => _testersOpen = !_testersOpen),
            ),
            _TaskStatsBox(
              label: '${l10n.reportTasksCount}: ${report.taskStats.total}',
              stats: report.taskStats,
              open: _tasksOpen,
              onTap: () => setState(() => _tasksOpen = !_tasksOpen),
            ),
          ],
        ),
      ),
    );
  }
}

String _statusLabel(ProjectStatus status, AppLocalizations l10n) =>
    switch (status) {
      ProjectStatus.planning => l10n.projectStatusPlanning,
      ProjectStatus.active => l10n.projectStatusActive,
      ProjectStatus.overdue => l10n.projectStatusOverdue,
      ProjectStatus.completed => l10n.projectStatusCompleted,
      ProjectStatus.cancelled => l10n.projectStatusCancelled,
      ProjectStatus.unknown => '',
    };

class _Chip extends StatelessWidget {
  const _Chip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        child: text
            .s(11.sp)
            .w(500)
            .c(colors.textStrong)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _KeyValueRow extends StatelessWidget {
  const _KeyValueRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.s(11.sp).w(500).c(colors.textSub),
        value.s(11.sp).w(800).c(colors.textStrong),
      ],
    );
  }
}

/// Har doim ochiq qator (Muallif/Boshqaruvchi) — ochilib-yopilmaydi.
class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4.h,
          children: [
            label.s(9.sp).w(500).c(colors.textStrong),
            value
                .s(11.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Ochilib-yopiladigan qator (Xodimlar/Sinovchilar) — yopiq holatda faqat
/// yorliq + chevron, ochiq holatda qiymat ko'rinadi.
class _ExpandableBox extends StatelessWidget {
  const _ExpandableBox({
    required this.label,
    required this.value,
    required this.open,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4.h,
            children: [
              Row(
                children: [
                  Expanded(child: label.s(9.sp).w(500).c(colors.textStrong)),
                  Assets.icons.icTuilconChervonDown.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              if (open)
                value
                    .s(11.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Vazifalar" bo'limi — yopiq holatda son + chevron, ochiq holatda har bir
/// holat bo'yicha rangli nuqta + son.
class _TaskStatsBox extends StatelessWidget {
  const _TaskStatsBox({
    required this.label,
    required this.stats,
    required this.open,
    required this.onTap,
  });

  final String label;
  final ProjectTaskStats stats;
  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final rows = [
      (l10n.reportTodo, stats.todo, colors.taskStatusTodo),
      (
        l10n.taskStatusInProgress,
        stats.inProgress,
        colors.taskStatusInProgress,
      ),
      (l10n.taskStatusDone, stats.done, colors.taskStatusDone),
      (
        l10n.taskStatusProduction,
        stats.production,
        colors.taskStatusProduction,
      ),
      (l10n.taskStatusChecked, stats.checked, colors.taskStatusChecked),
      (l10n.taskStatusRejected, stats.rejected, colors.taskStatusRejected),
      (l10n.taskStatusOverdue, stats.overdue, colors.taskStatusOverdue),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6.h,
            children: [
              Row(
                children: [
                  Expanded(child: label.s(11.sp).w(500).c(colors.textSub)),
                  Assets.icons.icTuilconChervonDown.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              if (open)
                for (final (statusLabel, count, color) in rows)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: SizedBox(width: 12.w, height: 12.w),
                      ),
                      SizedBox(width: 4.w),
                      '$statusLabel: $count'
                          .s(11.sp)
                          .w(500)
                          .c(colors.textStrong),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
