import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_filter.dart';
import '../../domain/usecases/project_usecases.dart';

part 'projects_event.dart';
part 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  ProjectsBloc({
    required GetProjectsUseCase getProjects,
    required DeleteProjectUseCase deleteProject,
  }) : _getProjects = getProjects,
       _deleteProject = deleteProject,
       super(const ProjectsState()) {
    on<ProjectsRequested>(_onRequested);
    on<ProjectsLoadMore>(_onLoadMore);
    on<ProjectsSearchChanged>(_onSearchChanged);
    on<ProjectsStatusChanged>(_onStatusChanged);
    on<ProjectsFilterChanged>(_onFilterChanged);
    on<ProjectDeleted>(_onDeleted);
  }

  final GetProjectsUseCase _getProjects;
  final DeleteProjectUseCase _deleteProject;

  Future<void> _onRequested(
    ProjectsRequested event,
    Emitter<ProjectsState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    ProjectsSearchChanged event,
    Emitter<ProjectsState> emit,
  ) => _reload(state.filter.copyWith(search: event.query), emit);

  Future<void> _onStatusChanged(
    ProjectsStatusChanged event,
    Emitter<ProjectsState> emit,
  ) => _reload(state.filter.copyWithStatus(event.status), emit);

  Future<void> _onFilterChanged(
    ProjectsFilterChanged event,
    Emitter<ProjectsState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(
    ProjectFilter filter,
    Emitter<ProjectsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectsStatus.loading, filter: filter));
    try {
      final page = await _getProjects((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: ProjectsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
          totalCount: page.totalCount,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(status: ProjectsStatus.failure, failure: failure));
    }
  }

  Future<void> _onLoadMore(
    ProjectsLoadMore event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state.status != ProjectsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getProjects((page: next, filter: state.filter));
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: next,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
          totalCount: page.totalCount,
        ),
      );
    } on Failure catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onDeleted(
    ProjectDeleted event,
    Emitter<ProjectsState> emit,
  ) async {
    final previous = state.items;
    emit(
      state.copyWith(
        items: previous.where((project) => project.id != event.id).toList(),
        totalCount: state.totalCount > 0 ? state.totalCount - 1 : 0,
      ),
    );
    try {
      await _deleteProject(event.id);
    } on Failure catch (_) {
      emit(state.copyWith(items: previous, totalCount: state.totalCount + 1));
    }
  }
}
