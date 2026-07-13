import '../../domain/entities/task.dart';

/// [Task] JSON serializatsiyasi (`/tasks/`).
///
/// Barcha maydonlar null-xavfsiz o'qiladi: backend `project_info` ni matn yoki
/// nested obyekt, ijrochini `assignee_info` obyektida qaytarishi mumkin.
class TaskModel extends Task {
  const TaskModel({
    required super.id,
    required super.uid,
    required super.title,
    required super.description,
    required super.projectInfo,
    required super.status,
    required super.priority,
    required super.deadline,
    required super.estimatedMinutes,
    required super.assigneeName,
    required super.assigneePosition,
    required super.assigneeAvatar,
    super.createdByAvatar,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';

    String pick(Map<String, dynamic> src, List<String> keys) {
      for (final k in keys) {
        final v = src[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return '';
    }

    // ── project_info: matn yoki nested {name/title} ────────────────────────
    String projectInfo() {
      final p = json['project_info'];
      if (p is Map) return pick(p.cast<String, dynamic>(), ['name', 'title']);
      return str(p);
    }

    // ── assignee_info: {username, position, avatar} ────────────────────────
    final assignee = json['assignee_info'];
    final aMap = assignee is Map
        ? assignee.cast<String, dynamic>()
        : const <String, dynamic>{};
    final createdBy = json['created_by_info'];
    final cMap = createdBy is Map
        ? createdBy.cast<String, dynamic>()
        : const <String, dynamic>{};

    final estimated = json['estimated_minutes'];

    return TaskModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uid: pick(json, ['uid', 'code']),
      title: str(json['title']),
      description: str(json['description']),
      projectInfo: projectInfo(),
      status: TaskStatus.fromApi(json['status'] as String?),
      priority: TaskPriority.fromApi(json['priority'] as String?),
      deadline: DateTime.tryParse(str(json['deadline'])),
      estimatedMinutes: estimated is num ? estimated.toInt() : null,
      assigneeName: pick(aMap, ['username', 'full_name', 'name']),
      assigneePosition: pick(aMap, ['position']),
      assigneeAvatar: pick(aMap, ['avatar']),
      createdByAvatar: pick(cMap, ['avatar']),
    );
  }
}
