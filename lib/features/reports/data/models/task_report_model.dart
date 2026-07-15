import '../../../tasks/domain/entities/task.dart';
import '../../domain/entities/task_report.dart';

class TaskReportModel extends TaskReport {
  const TaskReportModel({
    required super.id,
    required super.project,
    required super.prefix,
    required super.title,
    required super.createdBy,
    required super.assignee,
    required super.position,
    required super.priority,
    required super.status,
    required super.type,
    required super.taskPrice,
    required super.penaltyPercentage,
    required super.reopenedCount,
    required super.rejectionReason,
    required super.deadline,
    required super.createdAt,
  });

  factory TaskReportModel.fromJson(Map<String, dynamic> json) =>
      TaskReportModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        project: json['project']?.toString() ?? '',
        prefix: json['prefix']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        createdBy: json['created_by']?.toString() ?? '',
        assignee: json['assignee']?.toString() ?? '',
        position: json['position']?.toString() ?? '',
        priority: TaskPriority.fromApi(json['priority'] as String?),
        status: TaskStatus.fromApi(json['status'] as String?),
        type: TaskType.fromApi(json['type'] as String?),
        taskPrice: _number(json['task_price']),
        penaltyPercentage: _number(json['penalty_percentage']),
        reopenedCount: (json['reopened_count'] as num?)?.toInt() ?? 0,
        rejectionReason: json['rejection_reason']?.toString() ?? '',
        deadline: _date(json['deadline']),
        createdAt: _date(json['created_at']),
      );

  static num _number(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
