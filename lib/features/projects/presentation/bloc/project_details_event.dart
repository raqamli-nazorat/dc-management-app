part of 'project_details_bloc.dart';

sealed class ProjectDetailsEvent extends Equatable {
  const ProjectDetailsEvent();

  @override
  List<Object?> get props => [];
}

class ProjectDetailsRequested extends ProjectDetailsEvent {
  const ProjectDetailsRequested(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}
