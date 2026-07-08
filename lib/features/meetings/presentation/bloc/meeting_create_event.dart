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
