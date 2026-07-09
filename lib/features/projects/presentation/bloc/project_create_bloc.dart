import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_managers_usecase.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_form.dart';
import '../../domain/usecases/project_usecases.dart';

part 'project_create_event.dart';
part 'project_create_state.dart';

class ProjectCreateBloc extends Bloc<ProjectCreateEvent, ProjectCreateState> {
  ProjectCreateBloc({
    required GetManagersUseCase getManagers,
    required GetUsersUseCase getUsers,
    required CreateProjectUseCase createProject,
  }) : _getManagers = getManagers,
       _getUsers = getUsers,
       _createProject = createProject,
       super(const ProjectCreateState()) {
    on<ProjectCreateOptionsRequested>(_onRequested);
    on<ProjectCreateSubmitted>(_onSubmitted);
  }

  final GetManagersUseCase _getManagers;
  final GetUsersUseCase _getUsers;
  final CreateProjectUseCase _createProject;

  Future<void> _onRequested(
    ProjectCreateOptionsRequested event,
    Emitter<ProjectCreateState> emit,
  ) async {
    emit(state.copyWith(optionsLoading: true));
    try {
      final options = await Future.wait([_getUsers(), _getManagers()]);
      emit(
        state.copyWith(
          optionsLoading: false,
          users: options[0],
          managers: options[1],
        ),
      );
    } on Failure catch (_) {
      emit(state.copyWith(optionsLoading: false));
    }
  }

  Future<void> _onSubmitted(
    ProjectCreateSubmitted event,
    Emitter<ProjectCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: ProjectCreateSubmitStatus.submitting));
    try {
      final project = await _createProject(event.form);
      emit(
        state.copyWith(
          submitStatus: ProjectCreateSubmitStatus.success,
          project: project,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          submitStatus: ProjectCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }
}
