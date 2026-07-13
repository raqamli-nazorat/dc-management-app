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
