import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project_report.dart';
import '../../domain/entities/project_report_filter.dart';
import '../../domain/usecases/get_project_reports_usecase.dart';

part 'project_reports_event.dart';
part 'project_reports_state.dart';

/// Loyihalar bo'yicha hisobot ro'yxati bloci (`GET /reports/projects/`).
class ProjectReportsBloc extends Bloc<ProjectReportsEvent, ProjectReportsState> {
  ProjectReportsBloc({required GetProjectReportsUseCase getProjectReports})
    : _getProjectReports = getProjectReports,
      super(const ProjectReportsState()) {
    on<ProjectReportsRequested>(_onRequested);
    on<ProjectReportsLoadMore>(_onLoadMore);
    on<ProjectReportsSearchChanged>(_onSearchChanged);
    on<ProjectReportsFilterChanged>(_onFilterChanged);
  }

  final GetProjectReportsUseCase _getProjectReports;

  Future<void> _onRequested(
    ProjectReportsRequested event,
    Emitter<ProjectReportsState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    ProjectReportsSearchChanged event,
    Emitter<ProjectReportsState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _onFilterChanged(
    ProjectReportsFilterChanged event,
    Emitter<ProjectReportsState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(
    ProjectReportFilter filter,
    Emitter<ProjectReportsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectReportsStatus.loading, filter: filter));
    try {
      final page = await _getProjectReports((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: ProjectReportsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: ProjectReportsStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    ProjectReportsLoadMore event,
    Emitter<ProjectReportsState> emit,
  ) async {
    if (state.status != ProjectReportsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getProjectReports((page: next, filter: state.filter));
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
