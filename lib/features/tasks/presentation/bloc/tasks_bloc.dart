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
    on<TasksLoadMore>(_onLoadMore);
  }

  final GetTasksUseCase _getTasks;

  Future<void> _onRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) async {
    emit(state.copyWith(status: TasksStatus.loading));
    try {
      final page = await _getTasks(1);
      emit(
        state.copyWith(
          status: TasksStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: TasksStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    TasksLoadMore event,
    Emitter<TasksState> emit,
  ) async {
    if (state.status != TasksStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getTasks(next);
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: next,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (_) {
      // Load-more xatosi ro'yxatni buzmaydi — spinnerni o'chirib qo'yamiz.
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
