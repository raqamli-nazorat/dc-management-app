part of 'task_reports_filter_bloc.dart';

class TaskReportsFilterState extends Equatable {
  const TaskReportsFilterState({
    this.loading = false,
    this.positions = const [],
    this.projects = const [],
    this.users = const [],
  });

  final bool loading;
  final List<Position> positions;
  final List<ProjectShort> projects;
  final List<UserShort> users;

  TaskReportsFilterState copyWith({
    bool? loading,
    List<Position>? positions,
    List<ProjectShort>? projects,
    List<UserShort>? users,
  }) => TaskReportsFilterState(
    loading: loading ?? this.loading,
    positions: positions ?? this.positions,
    projects: projects ?? this.projects,
    users: users ?? this.users,
  );

  @override
  List<Object?> get props => [loading, positions, projects, users];
}
