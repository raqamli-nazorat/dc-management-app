part of 'meeting_create_bloc.dart';

sealed class MeetingCreateEvent extends Equatable {
  const MeetingCreateEvent();

  @override
  List<Object?> get props => [];
}

class MeetingCreateOptionsRequested extends MeetingCreateEvent {
  const MeetingCreateOptionsRequested();
}

class MeetingCreateProjectSelected extends MeetingCreateEvent {
  const MeetingCreateProjectSelected(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Tafsilotlarni yuklash (`GET /meetings/{id}/`) — detail rejimida forma
/// to'liq ma'lumot bilan yangilanadi (ro'yxat payload'i to'liq bo'lmasligi
/// mumkin).
class MeetingDetailRequested extends MeetingCreateEvent {
  const MeetingDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

class MeetingCreateSubmitted extends MeetingCreateEvent {
  const MeetingCreateSubmitted({
    required this.form,
    required this.closeAfterCreate,
  });

  final MeetingForm form;
  final bool closeAfterCreate;

  @override
  List<Object?> get props => [form, closeAfterCreate];
}

/// Tashkilotchi yig'ilishni yakunlaydi: avval qatnashuv yozuvlari
/// (`GET /meeting-attendance/?meeting=`) tanlovga moslab PATCH qilinadi,
/// so'ng `POST /meetings/{id}/close/`.
class MeetingCloseWithAttendanceSubmitted extends MeetingCreateEvent {
  const MeetingCloseWithAttendanceSubmitted({
    required this.meetingId,
    required this.attendedUserIds,
  });

  final int meetingId;

  /// Sheetda belgilangan (qatnashgan) foydalanuvchi id'lari.
  final Set<int> attendedUserIds;

  @override
  List<Object?> get props => [meetingId, attendedUserIds];
}

/// Tahrirlashni yuborish (`PUT /meetings/{id}/`; kerak bo'lsa keyin yopish).
class MeetingUpdateSubmitted extends MeetingCreateEvent {
  const MeetingUpdateSubmitted({
    required this.id,
    required this.form,
    required this.closeAfterUpdate,
  });

  final int id;
  final MeetingForm form;

  /// Toggle yoqildi, lekin yig'ilish hali yopilmagan — saqlashdan so'ng
  /// `POST /meetings/{id}/close/` chaqiriladi (schema'da `is_completed`
  /// readOnly, uni PUT bilan o'zgartirib bo'lmaydi).
  final bool closeAfterUpdate;

  @override
  List<Object?> get props => [id, form, closeAfterUpdate];
}
