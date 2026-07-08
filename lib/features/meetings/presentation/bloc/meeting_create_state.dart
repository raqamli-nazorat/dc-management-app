part of 'meeting_create_bloc.dart';

enum MeetingCreateSubmitStatus { idle, submitting, success, failure }

class MeetingCreateState extends Equatable {
  const MeetingCreateState({
    this.projects = const [],
    this.members = const [],
    this.membersLoading = false,
    this.submitStatus = MeetingCreateSubmitStatus.idle,
    this.submitFailure,
  });

  final List<ProjectShort> projects;
  final List<ProjectMember> members;
  final bool membersLoading;
  final MeetingCreateSubmitStatus submitStatus;
  final Failure? submitFailure;

  MeetingCreateState copyWith({
    List<ProjectShort>? projects,
    List<ProjectMember>? members,
    bool? membersLoading,
    MeetingCreateSubmitStatus? submitStatus,
    Failure? submitFailure,
  }) => MeetingCreateState(
    projects: projects ?? this.projects,
    members: members ?? this.members,
    membersLoading: membersLoading ?? this.membersLoading,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure ?? this.submitFailure,
  );

  @override
  List<Object?> get props => [
    projects,
    members,
    membersLoading,
    submitStatus,
    submitFailure,
  ];
}
