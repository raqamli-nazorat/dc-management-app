import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/util/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/task_report.dart';

/// Vazifa hisoboti kartasi (Figma: 1826-382108 / 1845-470249).
class TaskReportCard extends StatelessWidget {
  const TaskReportCard({required this.report, super.key});
  final TaskReport report;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
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
                      report.project
                          .s(13.sp)
                          .w(500)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      report.title
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
                if (report.prefix.isNotEmpty) ...[
                  SizedBox(width: 8.w),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.backgroundElevation1Alt,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      child: report.prefix
                          .s(11.sp)
                          .w(500)
                          .c(colors.textStrong),
                    ),
                  ),
                ],
              ],
            ),
            if (report.createdBy.isNotEmpty)
              _AltBox(label: l10n.taskFilterAuthor, value: report.createdBy),
            if (report.assignee.isNotEmpty)
              _AltBox(label: l10n.expenseReportUser, value: report.assignee),
            if (report.position.isNotEmpty)
              _AltBox(label: l10n.reportFilterPosition, value: report.position),
            _PlainRow(
              label: l10n.taskReportPrice,
              value: Formatters.formatAmount(
                report.taskPrice.toStringAsFixed(2),
              ),
            ),
            _PlainRow(
              label: l10n.taskReportPenalty,
              value: '${report.penaltyPercentage}%',
            ),
            if (report.reopenedCount > 0)
              _PlainRow(
                label: l10n.taskReportReopened,
                value: '${report.reopenedCount}',
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.w,
              children: [
                Expanded(
                  child: _AltBox(
                    label: l10n.taskCreateFieldPriority,
                    value: _priorityLabel(report.priority, l10n),
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.taskFilterStatus,
                    value: _statusLabel(report.status, l10n),
                    dotColor: _statusColor(report.status, colors),
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.taskCreateFieldType,
                    value: _typeLabel(report.type, l10n),
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8.w,
              children: [
                Expanded(
                  child: _AltBox(
                    label: l10n.taskCreateFieldDeadline,
                    value: _fmt(report.deadline),
                  ),
                ),
                Expanded(
                  child: _AltBox(
                    label: l10n.expenseReportCreatedAt,
                    value: _fmt(report.createdAt),
                  ),
                ),
              ],
            ),
            if (report.rejectionReason.isNotEmpty)
              _AltBox(
                label: l10n.taskDetailRejectReason,
                value: report.rejectionReason,
              ),
          ],
        ),
      ),
    );
  }
}

String _fmt(DateTime? date) =>
    date == null ? '' : DateFormat('dd.MM.yyyy HH:mm').format(date);

/// `background-elevation-1-alt` foniga ega yorliq+qiymat bloki; `dotColor`
/// berilsa qiymat oldida holat nuqtasi chiziladi.
class _AltBox extends StatelessWidget {
  const _AltBox({required this.label, required this.value, this.dotColor});

  final String label;
  final String value;
  final Color? dotColor;

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
          spacing: 2.h,
          children: [
            SizedBox(
              width: double.infinity,
              child: label
                  .s(9.sp)
                  .w(500)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Row(
              children: [
                if (dotColor != null) ...[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: SizedBox(width: 8.w, height: 8.w),
                  ),
                  SizedBox(width: 4.w),
                ],
                Expanded(
                  child: value
                      .s(11.sp)
                      .w(500)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fonsiz, justify-between yorliq/qiymat qatori (narx/jarima).
class _PlainRow extends StatelessWidget {
  const _PlainRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label.s(11.sp).w(500).c(colors.textSub),
        Flexible(
          child: value
              .s(11.sp)
              .w(800)
              .c(colors.textStrong)
              .a(TextAlign.right)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

String _priorityLabel(TaskPriority value, AppLocalizations l10n) =>
    switch (value) {
      TaskPriority.low => l10n.taskPriorityLow,
      TaskPriority.medium => l10n.taskPriorityMedium,
      TaskPriority.high => l10n.taskPriorityHigh,
      TaskPriority.critical => l10n.taskPriorityCritical,
      TaskPriority.unknown => '',
    };

String _statusLabel(TaskStatus value, AppLocalizations l10n) => switch (value) {
  TaskStatus.todo => l10n.taskStatusTodo,
  TaskStatus.inProgress => l10n.taskStatusInProgress,
  TaskStatus.overdue => l10n.taskStatusOverdue,
  TaskStatus.done => l10n.taskStatusDone,
  TaskStatus.production => l10n.taskStatusProduction,
  TaskStatus.checked => l10n.taskStatusChecked,
  TaskStatus.rejected => l10n.taskStatusRejected,
  TaskStatus.unknown => '',
};

Color _statusColor(TaskStatus value, AppColors colors) => switch (value) {
  TaskStatus.todo => colors.taskStatusTodo,
  TaskStatus.inProgress => colors.taskStatusInProgress,
  TaskStatus.overdue => colors.taskStatusOverdue,
  TaskStatus.done => colors.taskStatusDone,
  TaskStatus.production => colors.taskStatusProduction,
  TaskStatus.checked => colors.taskStatusChecked,
  TaskStatus.rejected => colors.taskStatusRejected,
  TaskStatus.unknown => colors.textSoft,
};

String _typeLabel(TaskType? value, AppLocalizations l10n) => switch (value) {
  TaskType.bug => l10n.taskTypeBug,
  TaskType.extra => l10n.taskTypeAddition,
  TaskType.feature => l10n.taskTypeFeature,
  TaskType.research => l10n.taskTypeResearch,
  null => '',
};
