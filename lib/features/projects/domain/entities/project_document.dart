import 'package:equatable/equatable.dart';

typedef ProjectDocumentPage = ({
  List<ProjectDocument> items,
  int totalCount,
  bool hasMore,
});

/// Submitdan oldingi mahalliy hujjat havolasi (nomi + link).
typedef ProjectDocumentDraft = ({String name, String value});

class ProjectDocument extends Equatable {
  const ProjectDocument({
    required this.id,
    required this.project,
    required this.name,
    required this.value,
    required this.createdAt,
  });

  final int id;
  final int project;
  final String name;
  final String value;
  final DateTime? createdAt;

  String get fileUrl => value;

  String get fileName {
    if (name.isNotEmpty) return name;
    final segments = Uri.tryParse(fileUrl)?.pathSegments ?? const [];
    return segments.isEmpty ? fileUrl : segments.last;
  }

  @override
  List<Object?> get props => [id, project, name, value, createdAt];
}
