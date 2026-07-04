part of 'tasks_bloc.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.items = const [],
    this.failure,
  });

  final TasksStatus status;
  final List<Task> items;
  final Failure? failure;

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? items,
    Failure? failure,
  }) => TasksState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, items, failure];
}
