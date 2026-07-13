import '../../domain/entities/task.dart';
import '../../domain/entities/task_detail.dart';

/// [TaskDetail] JSON serializatsiyasi (`GET /tasks/{id}/`).
///
/// [TaskModel] singari bardoshli o'qiladi: `project_info` matn yoki nested
/// obyekt bo'lishi mumkin; `project` writeOnly bo'lgani uchun id nested
/// obyektdan ham qidiriladi.
class TaskDetailModel extends TaskDetail {
  const TaskDetailModel({
    required super.id,
    required super.projectId,
    required super.projectInfo,
    required super.title,
    required super.description,
    required super.status,
    required super.priority,
    required super.type,
    required super.assigneeId,
    required super.assigneeName,
    required super.assigneePosition,
    required super.assigneeAvatar,
    required super.positionId,
    required super.positionName,
    required super.createdByName,
    required super.deadline,
    required super.taskPrice,
    required super.penaltyPercentage,
    required super.sprint,
    required super.estimatedMinutes,
    required super.rejectionReason,
    required super.rejectionFiles,
  });

  factory TaskDetailModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    int? asInt(dynamic v) => v is num ? v.toInt() : int.tryParse(str(v));

    final project = json['project_info'];
    final pMap = project is Map
        ? project.cast<String, dynamic>()
        : const <String, dynamic>{};
    final assignee = json['assignee_info'];
    final aMap = assignee is Map
        ? assignee.cast<String, dynamic>()
        : const <String, dynamic>{};
    final position = json['position_info'];
    final posMap = position is Map
        ? position.cast<String, dynamic>()
        : const <String, dynamic>{};
    final aPosition = aMap['position'];
    final createdBy = json['created_by_info'];
    final cMap = createdBy is Map
        ? createdBy.cast<String, dynamic>()
        : const <String, dynamic>{};

    return TaskDetailModel(
      id: asInt(json['id']) ?? 0,
      projectId: asInt(json['project']) ?? asInt(pMap['id']),
      projectInfo: project is Map
          ? str(pMap['name'] ?? pMap['title'])
          : str(project),
      title: str(json['title']),
      description: str(json['description']),
      status: TaskStatus.fromApi(json['status'] as String?),
      priority: TaskPriority.fromApi(json['priority'] as String?),
      type: TaskType.fromApi(json['type'] as String?),
      assigneeId: asInt(aMap['id']),
      assigneeName: str(aMap['username'] ?? aMap['full_name'] ?? aMap['name']),
      assigneePosition: aPosition is Map
          ? str(aPosition['name'])
          : str(aPosition),
      assigneeAvatar: str(aMap['avatar']),
      positionId: asInt(posMap['id']),
      positionName: str(posMap['name']),
      createdByName: str(cMap['username'] ?? cMap['full_name'] ?? cMap['name']),
      deadline: DateTime.tryParse(str(json['deadline'])),
      taskPrice: str(json['task_price']),
      penaltyPercentage: str(json['penalty_percentage']),
      sprint: asInt(json['sprint']),
      estimatedMinutes: asInt(json['estimated_minutes']),
      rejectionReason: str(json['rejection_reason']),
      rejectionFiles: [
        for (final f
            in (json['rejection_files'] is List)
                ? json['rejection_files'] as List
                : const [])
          if (f is Map && f['file'] != null) f['file'].toString(),
      ],
    );
  }
}

/// [TaskAttachmentInfo] JSON serializatsiyasi (`/task-attachments/`).
class TaskAttachmentInfoModel extends TaskAttachmentInfo {
  const TaskAttachmentInfoModel({required super.id, required super.fileUrl});

  factory TaskAttachmentInfoModel.fromJson(Map<String, dynamic> json) =>
      TaskAttachmentInfoModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fileUrl: json['file']?.toString() ?? '',
      );
}
