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

/// Tashkilotchi qatnashmaslik sababi bo'yicha qaror qiladi
/// (`PATCH /meeting-attendance/{id}/` -> `{is_excused: true/false}`).
/// Rad etishda sabab saqlanadi — foydalanuvchi qayta yoza olmaydi va
/// qatnashmagan hisobida qoladi.
class MeetingExcuseDecided extends MeetingReasonEvent {
  const MeetingExcuseDecided({
    required this.attendanceId,
    required this.approved,
  });

  final int attendanceId;
  final bool approved;

  @override
  List<Object?> get props => [attendanceId, approved];
}

/// Qatnashmaslik sababini yuborish (attendance id state’dan olinadi).
class MeetingReasonSubmitted extends MeetingReasonEvent {
  const MeetingReasonSubmitted(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}
