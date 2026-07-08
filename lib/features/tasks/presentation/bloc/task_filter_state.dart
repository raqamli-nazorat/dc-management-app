part of 'task_filter_bloc.dart';

/// Filtr sahifasi tanlov ro'yxatlari. Tanlangan qiymatlar sahifa `State`ida
/// saqlanadi — bu yerda faqat dropdownlar uchun manba ro'yxatlar.
class TaskFilterState extends Equatable {
  const TaskFilterState({
    this.loading = false,
    this.projects = const [],
    this.users = const [],
  });

  final bool loading;
  final List<ProjectShort> projects;
  final List<UserShort> users;

  TaskFilterState copyWith({
    bool? loading,
    List<ProjectShort>? projects,
    List<UserShort>? users,
  }) => TaskFilterState(
    loading: loading ?? this.loading,
    projects: projects ?? this.projects,
    users: users ?? this.users,
  );

  @override
  List<Object?> get props => [loading, projects, users];
}
