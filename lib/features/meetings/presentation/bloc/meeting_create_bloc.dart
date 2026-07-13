import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_project_members_usecase.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';
import '../../domain/entities/meeting_form.dart';
import '../../domain/usecases/close_meeting_usecase.dart';
import '../../domain/usecases/create_meeting_usecase.dart';
import '../../domain/usecases/update_meeting_usecase.dart';

part 'meeting_create_event.dart';
part 'meeting_create_state.dart';

class MeetingCreateBloc extends Bloc<MeetingCreateEvent, MeetingCreateState> {
  MeetingCreateBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetProjectMembersUseCase getMembers,
    required CreateMeetingUseCase createMeeting,
    required UpdateMeetingUseCase updateMeeting,
    required CloseMeetingUseCase closeMeeting,
  }) : _getOptions = getOptions,
       _getMembers = getMembers,
       _createMeeting = createMeeting,
       _updateMeeting = updateMeeting,
       _closeMeeting = closeMeeting,
       super(const MeetingCreateState()) {
    on<MeetingCreateOptionsRequested>(_onRequested);
    on<MeetingCreateProjectSelected>(_onProjectSelected);
    on<MeetingCreateSubmitted>(_onSubmitted);
    on<MeetingUpdateSubmitted>(_onUpdateSubmitted);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetProjectMembersUseCase _getMembers;
  final CreateMeetingUseCase _createMeeting;
  final UpdateMeetingUseCase _updateMeeting;
  final CloseMeetingUseCase _closeMeeting;

  Future<void> _onRequested(
    MeetingCreateOptionsRequested event,
    Emitter<MeetingCreateState> emit,
  ) async {
    try {
      final options = await _getOptions();
      emit(state.copyWith(projects: options.projects));
    } on Failure catch (_) {
      // Tanlovlar yuklanmasa dropdown bo'sh qoladi.
    }
  }

  Future<void> _onProjectSelected(
    MeetingCreateProjectSelected event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(membersLoading: true, members: const []));
    try {
      final members = await _getMembers(event.projectId);
      emit(state.copyWith(membersLoading: false, members: members));
    } on Failure catch (_) {
      emit(state.copyWith(membersLoading: false));
    }
  }

  Future<void> _onSubmitted(
    MeetingCreateSubmitted event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.submitting));
    try {
      final meeting = await _createMeeting(event.form);
      if (event.closeAfterCreate && meeting.id > 0) {
        await _closeMeeting(meeting.id);
      }
      emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }

  Future<void> _onUpdateSubmitted(
    MeetingUpdateSubmitted event,
    Emitter<MeetingCreateState> emit,
  ) async {
    emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.submitting));
    try {
      await _updateMeeting(UpdateMeetingParams(id: event.id, form: event.form));
      if (event.closeAfterUpdate) await _closeMeeting(event.id);
      emit(state.copyWith(submitStatus: MeetingCreateSubmitStatus.success));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          submitStatus: MeetingCreateSubmitStatus.failure,
          submitFailure: failure,
        ),
      );
    }
  }
}
