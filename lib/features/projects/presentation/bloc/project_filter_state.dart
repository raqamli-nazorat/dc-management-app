part of 'project_filter_bloc.dart';

class ProjectFilterState extends Equatable {
  const ProjectFilterState({this.loading = false, this.users = const []});

  final bool loading;
  final List<UserShort> users;

  ProjectFilterState copyWith({bool? loading, List<UserShort>? users}) =>
      ProjectFilterState(
        loading: loading ?? this.loading,
        users: users ?? this.users,
      );

  @override
  List<Object?> get props => [loading, users];
}
