import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_form_options.dart';
import '../../domain/usecases/change_task_status_usecase.dart';
import '../../domain/usecases/get_project_members_usecase.dart';
import '../../domain/usecases/get_task_edit_data_usecase.dart';
import '../../domain/usecases/get_task_form_options_usecase.dart';
import '../../domain/usecases/submit_task_usecase.dart';
import '../../domain/usecases/update_task_usecase.dart';

part 'task_create_event.dart';
part 'task_create_state.dart';

/// Vazifa qo'shish/tahrirlash formasi bloci — tanlov ro'yxatlarini yuklaydi
/// (lavozimlar + loyihalar; loyiha tanlanganda ishtirokchilar), tahrirlashda
/// vazifa detali + fayllarini yuklaydi va formani yuboradi (yaratish yoki
/// PATCH + fayl o'chirish/qo'shish). Forma qiymatlari sahifa `State`ida.
class TaskCreateBloc extends Bloc<TaskCreateEvent, TaskCreateState> {
  TaskCreateBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetProjectMembersUseCase getMembers,
    required SubmitTaskUseCase submitTask,
    required GetTaskEditDataUseCase getEditData,
    required UpdateTaskUseCase updateTask,
    required ChangeTaskStatusUseCase changeStatus,
  }) : _getOptions = getOptions,
       _getMembers = getMembers,
       _submitTask = submitTask,
       _getEditData = getEditData,
       _updateTask = updateTask,
       _changeStatus = changeStatus,
       super(const TaskCreateState()) {
    on<TaskCreateOptionsRequested>(_onRequested);
    on<TaskCreateProjectSelected>(_onProjectSelected);
    on<TaskCreateSubmitted>(_onSubmitted);
    on<TaskCreateDetailRequested>(_onDetailRequested);
    on<TaskCreateUpdateSubmitted>(_onUpdateSubmitted);
    on<TaskCreateStatusSubmitted>(_onStatusSubmitted);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetProjectMembersUseCase _getMembers;
  final SubmitTaskUseCase _submitTask;
  final GetTaskEditDataUseCase _getEditData;
  final UpdateTaskUseCase _updateTask;
  final ChangeTaskStatusUseCase _changeStatus;

  Future<void> _onRequested(
    TaskCreateOptionsRequested event,
    Emitter<TaskCreateState> emit,
  ) async {
    try {
      final options = await _getOptions();
      emit(
        state.copyWith(
          positions: options.positions,
          projects: options.projects,
        ),
      );
    } on Failure catch (_) {
      // Yuklanmasa dropdownlar bo'sh (statEmpty) qoladi.
    }
  }

  Future<void> _onProjectSelected(
    TaskCreateProjectSelected event,
    Emitter<TaskCreateState> emit,
  ) async {
    emit(state.copyWith(membersLoading: true, members: const []));
    try {
      final members = await _getMembers(event.projectId);
      emit(state.copyWith(membersLoading: false, members: members));
    } on Failure catch (_) {
      // Ishtirokchilar yuklanmasa forma buzilmaydi — bo'sh ro'yxat qoladi.
      emit(state.copyWith(membersLoading: false));
    }
  }

  Future<void> _onSubmitted(
    TaskCreateSubmitted event,
    Emitter<TaskCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: TaskSubmitStatus.submitting));
    try {
      await _submitTask(event.params);
      emit(state.copyWith(submitStatus: TaskSubmitStatus.success));
    } on Failure catch (f) {
      emit(
        state.copyWith(
          submitStatus: TaskSubmitStatus.failure,
          submitFailure: f,
        ),
      );
    }
  }

  Future<void> _onDetailRequested(
    TaskCreateDetailRequested event,
    Emitter<TaskCreateState> emit,
  ) async {
    emit(state.copyWith(detailLoading: true));
    try {
      final data = await _getEditData(event.taskId);
      emit(
        state.copyWith(
          detailLoading: false,
          detail: data.detail,
          attachments: data.attachments,
        ),
      );
    } on Failure catch (_) {
      // Detal yuklanmasa sahifa xato + qayta urinish ko'rsatadi (bo'sh forma
      // bilan PATCH yuborib maydonlarni o'chirib yubormaslik uchun).
      emit(state.copyWith(detailLoading: false));
    }
  }

  Future<void> _onStatusSubmitted(
    TaskCreateStatusSubmitted event,
    Emitter<TaskCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: TaskSubmitStatus.submitting));
    try {
      await _changeStatus(event.params);
      emit(state.copyWith(submitStatus: TaskSubmitStatus.success));
    } on Failure catch (f) {
      emit(
        state.copyWith(
          submitStatus: TaskSubmitStatus.failure,
          submitFailure: f,
        ),
      );
    }
  }

  Future<void> _onUpdateSubmitted(
    TaskCreateUpdateSubmitted event,
    Emitter<TaskCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: TaskSubmitStatus.submitting));
    try {
      await _updateTask(event.params);
      emit(state.copyWith(submitStatus: TaskSubmitStatus.success));
    } on Failure catch (f) {
      emit(
        state.copyWith(
          submitStatus: TaskSubmitStatus.failure,
          submitFailure: f,
        ),
      );
    }
  }
}
