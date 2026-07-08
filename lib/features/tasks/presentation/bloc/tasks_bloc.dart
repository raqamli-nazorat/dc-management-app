import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';

part 'tasks_event.dart';
part 'tasks_state.dart';

/// Vazifalar ro'yxati bloci (`GET /tasks/` — sahifalash + filtr + qidiruv).
class TasksBloc extends Bloc<TasksEvent, TasksState> {
  TasksBloc({
    required GetTasksUseCase getTasks,
    required DeleteTaskUseCase deleteTask,
  }) : _getTasks = getTasks,
       _deleteTask = deleteTask,
       super(const TasksState()) {
    on<TasksRequested>(_onRequested);
    on<TasksLoadMore>(_onLoadMore);
    on<TasksFilterChanged>(_onFilterChanged);
    on<TasksSearchChanged>(_onSearchChanged);
    on<TasksTaskDeleted>(_onTaskDeleted);
  }

  final GetTasksUseCase _getTasks;
  final DeleteTaskUseCase _deleteTask;

  Future<void> _onRequested(
    TasksRequested event,
    Emitter<TasksState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onFilterChanged(
    TasksFilterChanged event,
    Emitter<TasksState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _onSearchChanged(
    TasksSearchChanged event,
    Emitter<TasksState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  /// 1-sahifani berilgan [filter] bilan qaytadan yuklaydi (filtr saqlanadi).
  Future<void> _reload(TaskFilter filter, Emitter<TasksState> emit) async {
    emit(state.copyWith(status: TasksStatus.loading, filter: filter));
    try {
      final page = await _getTasks((page: 1, filter: filter));
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
      final page = await _getTasks((page: next, filter: state.filter));
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

  /// Optimistik o'chirish: elementni darrov ro'yxatdan olib tashlaymiz, so'ng
  /// API'ni chaqiramiz; xato bo'lsa ro'yxatni tiklaymiz.
  Future<void> _onTaskDeleted(
    TasksTaskDeleted event,
    Emitter<TasksState> emit,
  ) async {
    final previous = state.items;
    emit(
      state.copyWith(
        items: previous.where((t) => t.id != event.id).toList(),
      ),
    );
    try {
      await _deleteTask(event.id);
    } on Failure catch (_) {
      // Tiklaymiz (o'chirilmadi).
      emit(state.copyWith(items: previous));
    }
  }
}
