part of 'project_reports_filter_bloc.dart';

class ProjectReportsFilterState extends Equatable {
  const ProjectReportsFilterState({
    this.loading = false,
    this.users = const [],
  });

  final bool loading;
  final List<UserShort> users;

  ProjectReportsFilterState copyWith({bool? loading, List<UserShort>? users}) =>
      ProjectReportsFilterState(
        loading: loading ?? this.loading,
        users: users ?? this.users,
      );

  @override
  List<Object?> get props => [loading, users];
}
