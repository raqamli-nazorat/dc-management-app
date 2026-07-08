import '../../domain/entities/task_form_options.dart';

/// [Position] JSON serializatsiyasi (`/applications/positions/` → `results[]`).
class PositionModel extends Position {
  const PositionModel({required super.id, required super.name});

  factory PositionModel.fromJson(Map<String, dynamic> json) => PositionModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name']?.toString() ?? '',
  );
}

/// [ProjectShort] JSON serializatsiyasi (`/project-shorts/` → `results[]`).
class ProjectShortModel extends ProjectShort {
  const ProjectShortModel({
    required super.id,
    required super.title,
    required super.description,
    required super.deadline,
  });

  factory ProjectShortModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    return ProjectShortModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: str(json['title']),
      description: str(json['description']),
      deadline: DateTime.tryParse(str(json['deadline'])),
    );
  }
}

/// [UserShort] JSON serializatsiyasi (`/users/all/` → `results[]`, `UserShort`).
class UserShortModel extends UserShort {
  const UserShortModel({
    required super.id,
    required super.username,
    required super.position,
    required super.avatar,
  });

  factory UserShortModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    return UserShortModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: str(json['username']),
      position: str(json['position']),
      avatar: str(json['avatar']),
    );
  }
}

/// [ProjectMember] JSON serializatsiyasi (loyiha detalidagi `*_info` obyektlar).
class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.username,
    required super.position,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    return ProjectMemberModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: str(json['username']),
      position: str(json['position']),
    );
  }

  /// `GET /projects/{id}/` `data` obyektidan ishtirokchilarni yig'adi va
  /// `id` bo'yicha deduplikatsiya qiladi. Manba tartibi: manager → yaratuvchi →
  /// testerlar → xodimlar.
  static List<ProjectMember> membersFromProjectJson(Map<String, dynamic> json) {
    final seen = <int>{};
    final out = <ProjectMember>[];

    void addOne(dynamic v) {
      if (v is Map) {
        final m = ProjectMemberModel.fromJson(v.cast<String, dynamic>());
        if (m.id != 0 && seen.add(m.id)) out.add(m);
      }
    }

    void addList(dynamic v) {
      if (v is List) {
        for (final e in v) {
          addOne(e);
        }
      }
    }

    addOne(json['manager_info']);
    addOne(json['created_by_info']);
    addList(json['testers_info']);
    addList(json['employees_info']);
    return out;
  }
}
