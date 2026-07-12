part of 'project_details_bloc.dart';

enum ProjectDetailsStatus { initial, loading, success, failure }

class ProjectDetailsState extends Equatable {
  const ProjectDetailsState({
    this.status = ProjectDetailsStatus.initial,
    this.project,
    this.failure,
  });

  final ProjectDetailsStatus status;
  final Project? project;
  final Failure? failure;

  ProjectDetailsState copyWith({
    ProjectDetailsStatus? status,
    Project? project,
    Failure? failure,
  }) => ProjectDetailsState(
    status: status ?? this.status,
    project: project ?? this.project,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, project, failure];
}
