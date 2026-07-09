part of 'projects_bloc.dart';

sealed class ProjectsEvent extends Equatable {
  const ProjectsEvent();

  @override
  List<Object?> get props => [];
}

class ProjectsRequested extends ProjectsEvent {
  const ProjectsRequested();
}

class ProjectsLoadMore extends ProjectsEvent {
  const ProjectsLoadMore();
}

class ProjectsSearchChanged extends ProjectsEvent {
  const ProjectsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ProjectsStatusChanged extends ProjectsEvent {
  const ProjectsStatusChanged(this.status);

  final ProjectStatus? status;

  @override
  List<Object?> get props => [status];
}

class ProjectsFilterChanged extends ProjectsEvent {
  const ProjectsFilterChanged(this.filter);

  final ProjectFilter filter;

  @override
  List<Object?> get props => [filter];
}

class ProjectDeleted extends ProjectsEvent {
  const ProjectDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
