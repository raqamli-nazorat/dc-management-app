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
    required UpdateProjectUseCase updateProject,
    required UploadProjectDocumentUseCase uploadDocument,
  }) : _getManagers = getManagers,
       _getUsers = getUsers,
       _createProject = createProject,
       _updateProject = updateProject,
       _uploadDocument = uploadDocument,
       super(const ProjectCreateState()) {
    on<ProjectCreateOptionsRequested>(_onRequested);
    on<ProjectCreateSubmitted>(_onSubmitted);
    on<ProjectUpdated>(_onUpdated);
  }

  final GetManagersUseCase _getManagers;
  final GetUsersUseCase _getUsers;
  final CreateProjectUseCase _createProject;
  final UpdateProjectUseCase _updateProject;
  final UploadProjectDocumentUseCase _uploadDocument;

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
      // Loyiha yaratildi — hujjat yuklashdagi xato yaratishni bekor qilmaydi
      // (aks holda qayta urinish loyihani ikkilantiradi); xato alohida
      // bayroq bilan sahifaga yetkaziladi.
      var documentsFailed = false;
      for (final path in event.filePaths) {
        try {
          await _uploadDocument((projectId: project.id, filePath: path));
        } on Failure catch (_) {
          documentsFailed = true;
        }
      }
      emit(
        state.copyWith(
          submitStatus: ProjectCreateSubmitStatus.success,
          project: project,
          documentsFailed: documentsFailed,
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

  Future<void> _onUpdated(
    ProjectUpdated event,
    Emitter<ProjectCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: ProjectCreateSubmitStatus.submitting));
    try {
      final project = await _updateProject((id: event.id, form: event.form));
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
