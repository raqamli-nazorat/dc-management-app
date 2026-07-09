import '../../domain/entities/project_document.dart';

class ProjectDocumentModel extends ProjectDocument {
  const ProjectDocumentModel({
    required super.id,
    required super.project,
    required super.name,
    required super.value,
    required super.createdAt,
  });

  factory ProjectDocumentModel.fromJson(Map<String, dynamic> json) {
    String str(dynamic v) => v?.toString() ?? '';
    return ProjectDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      project: (json['project'] as num?)?.toInt() ?? 0,
      name: str(json['name']),
      value: str(json['value']),
      createdAt: DateTime.tryParse(str(json['created_at'])),
    );
  }
}
