part of 'project_create_bloc.dart';

sealed class ProjectCreateEvent extends Equatable {
  const ProjectCreateEvent();

  @override
  List<Object?> get props => [];
}

class ProjectCreateOptionsRequested extends ProjectCreateEvent {
  const ProjectCreateOptionsRequested();
}

class ProjectDocumentsRequested extends ProjectCreateEvent {
  const ProjectDocumentsRequested(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}

class ProjectCreateSubmitted extends ProjectCreateEvent {
  const ProjectCreateSubmitted(this.form, {this.filePaths = const []});

  final ProjectForm form;

  /// Loyiha yaratilgach biriktiriladigan hujjatlar (doc/pdf/excel).
  final List<String> filePaths;

  @override
  List<Object?> get props => [form, filePaths];
}

class ProjectUpdated extends ProjectCreateEvent {
  const ProjectUpdated(
    this.id,
    this.form, {
    this.filePaths = const [],
    this.removedDocumentIds = const [],
  });

  final int id;
  final ProjectForm form;
  final List<String> filePaths;
  final List<int> removedDocumentIds;

  @override
  List<Object?> get props => [id, form, filePaths, removedDocumentIds];
}
