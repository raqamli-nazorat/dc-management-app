import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/usecases/get_meeting_attendance_usecase.dart';
import '../../domain/usecases/get_meeting_usecase.dart';
import '../../domain/usecases/submit_absence_reason_usecase.dart';

part 'meeting_reason_event.dart';
part 'meeting_reason_state.dart';

/// "Yig‘ilishga qatnashmadingiz" ekrani bloci — yig‘ilish sarlavhasi + sanasini
/// va joriy foydalanuvchining qatnashuv yozuvini (`meeting-attendance`) yuklaydi,
/// so‘ng qatnashmaslik sababini shu yozuvga PATCH bilan yuboradi.
class MeetingReasonBloc extends Bloc<MeetingReasonEvent, MeetingReasonState> {
  MeetingReasonBloc({
    required GetMeetingUseCase getMeeting,
    required GetMeetingAttendanceUseCase getAttendance,
    required SubmitAbsenceReasonUseCase submitReason,
  }) : _getMeeting = getMeeting,
       _getAttendance = getAttendance,
       _submitReason = submitReason,
       super(const MeetingReasonState()) {
    on<MeetingReasonLoaded>(_onLoaded);
    on<MeetingReasonSubmitted>(_onSubmitted);
  }

  final GetMeetingUseCase _getMeeting;
  final GetMeetingAttendanceUseCase _getAttendance;
  final SubmitAbsenceReasonUseCase _submitReason;

  Future<void> _onLoaded(
    MeetingReasonLoaded event,
    Emitter<MeetingReasonState> emit,
  ) async {
    emit(state.copyWith(loadStatus: MeetingReasonLoad.loading));
    try {
      final attendance = await _getAttendance(event.meetingId);
      // Joriy foydalanuvchining yozuvi: ro‘yxat odatda so‘rovchiga
      // moslashtirilgan; qatnashmagan (is_attended=false) yozuvni ustun
      // ko‘ramiz, bo‘lmasa birinchisini.
      MeetingAttendance? mine;
      for (final a in attendance) {
        if (!a.isAttended) {
          mine = a;
          break;
        }
      }
      mine ??= attendance.isNotEmpty ? attendance.first : null;

      // Sana uchun yig‘ilishning o‘zini olamiz (best-effort — xato bo‘lsa
      // sarlavha attendance’dan olinadi, sana ko‘rsatilmaydi).
      DateTime? startDate;
      var title = mine?.meetingTitle ?? '';
      try {
        final meeting = await _getMeeting(event.meetingId);
        startDate = meeting.startDate;
        if (meeting.title.isNotEmpty) title = meeting.title;
      } on Failure {
        // e'tiborsiz — attendance’dan sarlavha yetarli.
      }

      emit(
        state.copyWith(
          loadStatus: MeetingReasonLoad.success,
          title: title,
          startDate: startDate,
          attendanceId: mine?.id,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(loadStatus: MeetingReasonLoad.failure, failure: f));
    }
  }

  Future<void> _onSubmitted(
    MeetingReasonSubmitted event,
    Emitter<MeetingReasonState> emit,
  ) async {
    final text = event.reason.trim();
    if (text.isEmpty) return;
    final attendanceId = state.attendanceId;
    if (attendanceId == null) {
      emit(
        state.copyWith(
          submitStatus: MeetingReasonSubmit.failure,
          failure: const ServerFailure(),
        ),
      );
      return;
    }
    emit(state.copyWith(submitStatus: MeetingReasonSubmit.loading));
    try {
      await _submitReason(
        SubmitAbsenceReasonParams(attendanceId: attendanceId, reason: text),
      );
      emit(state.copyWith(submitStatus: MeetingReasonSubmit.success));
    } on Failure catch (f) {
      emit(
        state.copyWith(submitStatus: MeetingReasonSubmit.failure, failure: f),
      );
    }
  }
}
