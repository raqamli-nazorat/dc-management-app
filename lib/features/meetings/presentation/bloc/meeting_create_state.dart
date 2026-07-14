part of 'meeting_create_bloc.dart';

enum MeetingCreateSubmitStatus { idle, submitting, success, failure }

class MeetingCreateState extends Equatable {
  const MeetingCreateState({
    this.projects = const [],
    this.members = const [],
    this.membersLoading = false,
    this.detail,
    this.submitStatus = MeetingCreateSubmitStatus.idle,
    this.submitFailure,
  });

  final List<ProjectShort> projects;
  final List<ProjectMember> members;
  final bool membersLoading;

  /// `GET /meetings/{id}/` javobi (detail rejimi).
  final Meeting? detail;

  final MeetingCreateSubmitStatus submitStatus;
  final Failure? submitFailure;

  MeetingCreateState copyWith({
    List<ProjectShort>? projects,
    List<ProjectMember>? members,
    bool? membersLoading,
    Meeting? detail,
    MeetingCreateSubmitStatus? submitStatus,
    Failure? submitFailure,
  }) => MeetingCreateState(
    projects: projects ?? this.projects,
    members: members ?? this.members,
    membersLoading: membersLoading ?? this.membersLoading,
    detail: detail ?? this.detail,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure ?? this.submitFailure,
  );

  @override
  List<Object?> get props => [
    projects,
    members,
    membersLoading,
    detail,
    submitStatus,
    submitFailure,
  ];
}
