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

  Future<void> _onRequested(TasksRequested event, Emitter<TasksState> emit) =>
      _reload(state.filter, emit);

  Future<void> _onFilterChanged(
    TasksFilterChanged event,
    Emitter<TasksState> emit,
  ) async {
    if (_emitCachedStatusPage(event.filter, emit)) return;
    await _reload(event.filter, emit);
  }

  Future<void> _onSearchChanged(
    TasksSearchChanged event,
    Emitter<TasksState> emit,
  ) => _reload(
    state.filter.copyWithSearch(event.query),
    emit,
    prefetchStatuses: event.query.trim().isEmpty,
  );

  bool _emitCachedStatusPage(TaskFilter filter, Emitter<TasksState> emit) {
    final status = filter.status;
    final baseFilter = filter.copyWithStatus(null);
    if (status == null || state.statusBaseFilter != baseFilter) return false;

    final snapshot = state.statusPages[status];
    if (snapshot == null) return false;

    emit(
      state.copyWith(
        status: TasksStatus.success,
        filter: filter,
        items: snapshot.items,
        page: snapshot.page,
        hasReachedMax: snapshot.hasReachedMax,
        isLoadingMore: false,
      ),
    );
    return true;
  }

  /// 1-sahifani berilgan [filter] bilan qaytadan yuklaydi (filtr saqlanadi).
  Future<void> _reload(
    TaskFilter filter,
    Emitter<TasksState> emit, {
    bool prefetchStatuses = true,
  }) async {
    final baseFilter = filter.copyWithStatus(null);
    emit(
      state.copyWith(
        status: TasksStatus.loading,
        filter: filter,
        statusPages: const {},
        clearStatusBaseFilter: true,
      ),
    );
    try {
      if (!prefetchStatuses) {
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
        return;
      }

      final currentPageFuture = filter.status == null
          ? _getTasks((page: 1, filter: filter))
          : null;
      final statusEntries = await Future.wait(
        taskFilterStatuses.map(
          (status) async => MapEntry(
            status,
            TaskStatusPageSnapshot.first(
              await _getTasks((
                page: 1,
                filter: baseFilter.copyWithStatus(status),
              )),
            ),
          ),
        ),
      );
      final statusPages = Map<TaskStatus, TaskStatusPageSnapshot>.fromEntries(
        statusEntries,
      );
      final currentSnapshot = filter.status == null
          ? TaskStatusPageSnapshot.first(await currentPageFuture!)
          : statusPages[filter.status]!;
      emit(
        state.copyWith(
          status: TasksStatus.success,
          items: currentSnapshot.items,
          page: currentSnapshot.page,
          hasReachedMax: currentSnapshot.hasReachedMax,
          isLoadingMore: false,
          statusPages: statusPages,
          statusBaseFilter: baseFilter,
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
      final status = state.filter.status;
      if (status != null &&
          state.statusBaseFilter == state.filter.copyWithStatus(null)) {
        final statusPages = Map<TaskStatus, TaskStatusPageSnapshot>.from(
          state.statusPages,
        );
        final snapshot = statusPages[status];
        final updated = snapshot == null
            ? TaskStatusPageSnapshot.first(page)
            : snapshot.append(page);
        statusPages[status] = updated;
        emit(
          state.copyWith(
            items: updated.items,
            page: updated.page,
            hasReachedMax: updated.hasReachedMax,
            isLoadingMore: false,
            statusPages: statusPages,
          ),
        );
        return;
      }
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
    final previousStatusPages = state.statusPages;
    final statusPages = {
      for (final entry in state.statusPages.entries)
        entry.key: entry.value.remove(event.id),
    };
    emit(
      state.copyWith(
        items: previous.where((t) => t.id != event.id).toList(),
        statusPages: statusPages,
      ),
    );
    try {
      await _deleteTask(event.id);
    } on Failure catch (_) {
      // Tiklaymiz (o'chirilmadi).
      emit(state.copyWith(items: previous, statusPages: previousStatusPages));
    }
  }
}
