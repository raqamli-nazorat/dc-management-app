part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan).
class TasksRequested extends TasksEvent {
  const TasksRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class TasksLoadMore extends TasksEvent {
  const TasksLoadMore();
}
