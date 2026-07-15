import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task_report.dart';
import '../../domain/entities/task_report_filter.dart';
import '../../domain/usecases/get_task_reports_usecase.dart';

part 'task_reports_event.dart';
part 'task_reports_state.dart';

class TaskReportsBloc extends Bloc<TaskReportsEvent, TaskReportsState> {
  TaskReportsBloc({required GetTaskReportsUseCase getTaskReports})
    : _getTaskReports = getTaskReports,
      super(const TaskReportsState()) {
    on<TaskReportsRequested>((_, emit) => _reload(state.filter, emit));
    on<TaskReportsSearchChanged>(
      (event, emit) => _reload(state.filter.copyWithSearch(event.query), emit),
    );
    on<TaskReportsFilterChanged>((event, emit) => _reload(event.filter, emit));
    on<TaskReportsLoadMore>(_onLoadMore);
  }

  final GetTaskReportsUseCase _getTaskReports;

  Future<void> _reload(
    TaskReportFilter filter,
    Emitter<TaskReportsState> emit,
  ) async {
    emit(state.copyWith(status: TaskReportsStatus.loading, filter: filter));
    try {
      final page = await _getTaskReports((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: TaskReportsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(status: TaskReportsStatus.failure, failure: failure));
    }
  }

  Future<void> _onLoadMore(
    TaskReportsLoadMore event,
    Emitter<TaskReportsState> emit,
  ) async {
    if (state.status != TaskReportsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getTaskReports((page: next, filter: state.filter));
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: next,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
