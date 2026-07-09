import 'package:equatable/equatable.dart';

typedef ProjectDocumentPage = ({
  List<ProjectDocument> items,
  int totalCount,
  bool hasMore,
});

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

  @override
  List<Object?> get props => [id, project, name, value, createdAt];
}
