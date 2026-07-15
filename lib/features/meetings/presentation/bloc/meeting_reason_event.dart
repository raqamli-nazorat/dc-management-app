part of 'meeting_reason_bloc.dart';

sealed class MeetingReasonEvent extends Equatable {
  const MeetingReasonEvent();

  @override
  List<Object?> get props => [];
}

/// Yig‘ilish + qatnashuv yozuvini yuklash (sarlavha, sana, attendance id).
class MeetingReasonLoaded extends MeetingReasonEvent {
  const MeetingReasonLoaded(this.meetingId);

  final int meetingId;

  @override
  List<Object?> get props => [meetingId];
}

/// Tashkilotchi qatnashmaslik sababini tasdiqlaydi
/// (`PATCH /meeting-attendance/{id}/` -> `{is_excused: true}`).
class MeetingExcuseApproved extends MeetingReasonEvent {
  const MeetingExcuseApproved(this.attendanceId);

  final int attendanceId;

  @override
  List<Object?> get props => [attendanceId];
}

/// Qatnashmaslik sababini yuborish (attendance id state’dan olinadi).
class MeetingReasonSubmitted extends MeetingReasonEvent {
  const MeetingReasonSubmitted(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}
