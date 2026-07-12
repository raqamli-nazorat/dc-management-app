part of 'project_create_bloc.dart';

sealed class ProjectCreateEvent extends Equatable {
  const ProjectCreateEvent();

  @override
  List<Object?> get props => [];
}

class ProjectCreateOptionsRequested extends ProjectCreateEvent {
  const ProjectCreateOptionsRequested();
}

class ProjectCreateSubmitted extends ProjectCreateEvent {
  const ProjectCreateSubmitted(this.form);

  final ProjectForm form;

  @override
  List<Object?> get props => [form];
}

class ProjectUpdated extends ProjectCreateEvent {
  const ProjectUpdated(this.id, this.form);

  final int id;
  final ProjectForm form;

  @override
  List<Object?> get props => [id, form];
}
