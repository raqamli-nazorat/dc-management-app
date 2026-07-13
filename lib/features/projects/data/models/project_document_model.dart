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
    final file = str(json['file'] ?? json['url'] ?? json['value']);
    final segments = Uri.tryParse(file)?.pathSegments ?? const <String>[];
    final fallbackName = segments.isEmpty ? file : segments.last;
    return ProjectDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      project: (json['project'] as num?)?.toInt() ?? 0,
      name: str(json['name']).isEmpty ? fallbackName : str(json['name']),
      value: file,
      createdAt: DateTime.tryParse(str(json['created_at'])),
    );
  }
}
