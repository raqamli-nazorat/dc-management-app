import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

/// Vazifalar ro'yxati bloci (`GET /tasks/`).
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({required GetTasksUseCase getTasks})
    : _getTasks = getTasks,
      super(const TasksState()) {
    on<TasksRequested>(_onRequested);
  }

  final GetTasksUseCase _getTasks;

  Future<void> _onRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final items = await _getTasks(null);
      emit(state.copyWith(status: TasksStatus.success, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: TasksStatus.failure, failure: f));
    }
  }
}
