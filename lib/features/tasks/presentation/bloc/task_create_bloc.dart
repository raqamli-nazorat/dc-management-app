import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task_form_options.dart';
import '../../domain/usecases/get_project_members_usecase.dart';
import '../../domain/usecases/get_task_form_options_usecase.dart';
import '../../domain/usecases/submit_task_usecase.dart';

part 'task_create_event.dart';
part 'task_create_state.dart';

/// Vazifa qo'shish formasi bloci — tanlov ro'yxatlarini yuklaydi (lavozimlar +
/// loyihalar; loyiha tanlanganda ishtirokchilar) va formani yuboradi (vazifa
/// yaratish + fayllarni biriktirish). Forma qiymatlari sahifa `State`ida.
class TaskCreateBloc extends Bloc<TaskCreateEvent, TaskCreateState> {
  TaskCreateBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetProjectMembersUseCase getMembers,
    required SubmitTaskUseCase submitTask,
  }) : _getOptions = getOptions,
       _getMembers = getMembers,
       _submitTask = submitTask,
       super(const TaskCreateState()) {
    on<TaskCreateOptionsRequested>(_onRequested);
    on<TaskCreateProjectSelected>(_onProjectSelected);
    on<TaskCreateSubmitted>(_onSubmitted);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetProjectMembersUseCase _getMembers;
  final SubmitTaskUseCase _submitTask;

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
}
