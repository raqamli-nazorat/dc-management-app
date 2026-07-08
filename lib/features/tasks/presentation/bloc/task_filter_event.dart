part of 'task_filter_bloc.dart';

sealed class TaskFilterEvent extends Equatable {
  const TaskFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlov ro'yxatlarini (loyihalar + lavozimlar + foydalanuvchilar) yuklash.
class TaskFilterOptionsRequested extends TaskFilterEvent {
  const TaskFilterOptionsRequested();
}
