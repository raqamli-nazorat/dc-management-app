import 'package:equatable/equatable.dart';

import '../../../tasks/domain/entities/task.dart';

typedef TaskReportPage = ({List<TaskReport> items, bool hasMore});

/// Vazifa bo'yicha hisobot qatori (`GET /reports/tasks/`, `TaskReport` schema).
/// `priority`/`status`/`type` — tasks feature'dagi umumiy enumlarga parse
/// qilinadi ([TaskPriority]/[TaskStatus]/[TaskType]).
class TaskReport extends Equatable {
  const TaskReport({
    required this.id,
    required this.project,
    required this.prefix,
    required this.title,
    required this.createdBy,
    required this.assignee,
    required this.position,
    required this.priority,
    required this.status,
    required this.type,
    required this.taskPrice,
    required this.penaltyPercentage,
    required this.reopenedCount,
    required this.rejectionReason,
    required this.deadline,
    required this.createdAt,
  });

  final int id;
  final String project;
  final String prefix;
  final String title;
  final String createdBy;
  final String assignee;
  final String position;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskType? type;
  final num taskPrice;
  final num penaltyPercentage;
  final int reopenedCount;
  final String rejectionReason;
  final DateTime? deadline;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    project,
    prefix,
    title,
    createdBy,
    assignee,
    position,
    priority,
    status,
    type,
    taskPrice,
    penaltyPercentage,
    reopenedCount,
    rejectionReason,
    deadline,
    createdAt,
  ];
}
