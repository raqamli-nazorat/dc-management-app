part of 'project_reports_filter_bloc.dart';

sealed class ProjectReportsFilterEvent extends Equatable {
  const ProjectReportsFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchilar ro'yxatini yuklash.
class ProjectReportsFilterOptionsRequested extends ProjectReportsFilterEvent {
  const ProjectReportsFilterOptionsRequested();
}
