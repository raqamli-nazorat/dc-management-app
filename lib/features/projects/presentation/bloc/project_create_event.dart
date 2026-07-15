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
  const ProjectCreateSubmitted(this.form, {this.documents = const []});

  final ProjectForm form;

  /// Loyiha yaratilgach biriktiriladigan hujjat havolalari.
  final List<ProjectDocumentDraft> documents;

  @override
  List<Object?> get props => [form, documents];
}

class ProjectUpdated extends ProjectCreateEvent {
  const ProjectUpdated(
    this.id,
    this.form, {
    this.documents = const [],
    this.removedDocumentIds = const [],
  });

  final int id;

  /// `null` — faqat hujjatlar o'zgargan (menejer rejimi): loyihaning o'zi
  /// PATCH qilinmaydi.
  final ProjectForm? form;
  final List<ProjectDocumentDraft> documents;
  final List<int> removedDocumentIds;

  @override
  List<Object?> get props => [id, form, documents, removedDocumentIds];
}
