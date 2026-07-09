part of 'project_filter_bloc.dart';

sealed class ProjectFilterEvent extends Equatable {
  const ProjectFilterEvent();

  @override
  List<Object?> get props => [];
}

class ProjectFilterOptionsRequested extends ProjectFilterEvent {
  const ProjectFilterOptionsRequested();
}
