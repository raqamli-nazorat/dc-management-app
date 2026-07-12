import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/project_usecases.dart';

part 'project_details_event.dart';
part 'project_details_state.dart';

class ProjectDetailsBloc
    extends Bloc<ProjectDetailsEvent, ProjectDetailsState> {
  ProjectDetailsBloc({required GetProjectUseCase getProject})
    : _getProject = getProject,
      super(const ProjectDetailsState()) {
    on<ProjectDetailsRequested>(_onRequested);
  }

  final GetProjectUseCase _getProject;

  Future<void> _onRequested(
    ProjectDetailsRequested event,
    Emitter<ProjectDetailsState> emit,
  ) async {
    emit(state.copyWith(status: ProjectDetailsStatus.loading));
    try {
      final project = await _getProject(event.projectId);
      emit(
        state.copyWith(status: ProjectDetailsStatus.success, project: project),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(status: ProjectDetailsStatus.failure, failure: failure),
      );
    }
  }
}
