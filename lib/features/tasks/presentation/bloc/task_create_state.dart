part of 'task_create_bloc.dart';

/// Formani yuborish holati (tugma spinneri + muvaffaqiyat/xato listeneri).
enum TaskSubmitStatus { idle, submitting, success, failure }

/// Forma tanlov ro'yxatlari + yuborish holati. Ro'yxatlar yuklanmasa bo'sh
/// qoladi (dropdown `statEmpty` ko'rsatadi) — ular uchun alohida status yo'q.
class TaskCreateState extends Equatable {
  const TaskCreateState({
    this.positions = const [],
    this.projects = const [],
    this.members = const [],
    this.membersLoading = false,
    this.submitStatus = TaskSubmitStatus.idle,
    this.submitFailure,
  });

  final List<Position> positions;
  final List<ProjectShort> projects;

  /// Tanlangan loyiha ishtirokchilari (Topshiruvchi tanlovi).
  final List<ProjectMember> members;

  /// Ishtirokchilar yuklanmoqda (loyiha endi tanlandi).
  final bool membersLoading;

  final TaskSubmitStatus submitStatus;
  final Failure? submitFailure;

  TaskCreateState copyWith({
    List<Position>? positions,
    List<ProjectShort>? projects,
    List<ProjectMember>? members,
    bool? membersLoading,
    TaskSubmitStatus? submitStatus,
    Failure? submitFailure,
  }) => TaskCreateState(
    positions: positions ?? this.positions,
    projects: projects ?? this.projects,
    members: members ?? this.members,
    membersLoading: membersLoading ?? this.membersLoading,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure ?? this.submitFailure,
  );

  @override
  List<Object?> get props => [
    positions,
    projects,
    members,
    membersLoading,
    submitStatus,
    submitFailure,
  ];
}
