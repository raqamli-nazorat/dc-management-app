part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash.
class TasksRequested extends TasksEvent {
  const TasksRequested();
}
