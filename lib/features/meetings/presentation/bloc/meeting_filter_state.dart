part of 'meeting_filter_bloc.dart';

class MeetingFilterState extends Equatable {
  const MeetingFilterState({
    this.loading = false,
    this.projects = const [],
    this.users = const [],
  });

  final bool loading;
  final List<ProjectShort> projects;
  final List<UserShort> users;

  MeetingFilterState copyWith({
    bool? loading,
    List<ProjectShort>? projects,
    List<UserShort>? users,
  }) => MeetingFilterState(
    loading: loading ?? this.loading,
    projects: projects ?? this.projects,
    users: users ?? this.users,
  );

  @override
  List<Object?> get props => [loading, projects, users];
}
