import '../../domain/entities/project.dart';

class ProjectParticipantModel extends ProjectParticipant {
  const ProjectParticipantModel({
    required super.id,
    required super.username,
    required super.position,
  });

  factory ProjectParticipantModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    String pick(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
      return '';
    }

    return ProjectParticipantModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: pick(['full_name', 'username', 'name']),
      position: str(json['position']),
    );
  }
}

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.uid,
    required super.prefix,
    required super.title,
    required super.description,
    required super.manager,
    required super.createdBy,
    required super.testers,
    required super.employees,
    required super.deadline,
    required super.status,
    required super.isHidden,
    required super.createdAt,
    required super.updatedAt,
    required super.completionPercentage,
    required super.projectPrice,
    required super.penaltyPercentage,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';

    ProjectParticipant? participant(dynamic value) {
      if (value is! Map) return null;
      final item = ProjectParticipantModel.fromJson(
        value.cast<String, dynamic>(),
      );
      return item.id == 0 && item.username.isEmpty ? null : item;
    }

    List<ProjectParticipant> participants(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map>()
          .map(
            (e) => ProjectParticipantModel.fromJson(e.cast<String, dynamic>()),
          )
          .where((e) => e.id != 0 || e.username.isNotEmpty)
          .toList();
    }

    return ProjectModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      uid: str(json['uid']),
      prefix: str(json['prefix']),
      title: str(json['title']),
      description: str(json['description']),
      manager: participant(json['manager_info']),
      createdBy: participant(json['created_by_info']),
      testers: participants(json['testers_info']),
      employees: participants(json['employees_info']),
      deadline: DateTime.tryParse(str(json['deadline'])),
      status: ProjectStatus.fromApi(json['status'] as String?),
      isHidden: json['is_hidden'] == true,
      createdAt: DateTime.tryParse(str(json['created_at'])),
      updatedAt: DateTime.tryParse(str(json['updated_at'])),
      completionPercentage: str(json['completion_percentage']),
      projectPrice: str(json['project_price']),
      penaltyPercentage: str(json['penalty_percentage']),
    );
  }
}
