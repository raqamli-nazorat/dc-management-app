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
    this.detail,
    this.detailLoading = false,
    this.attachments = const [],
    this.permissionContext,
  });

  final List<Position> positions;
  final List<ProjectShort> projects;

  /// Tanlangan loyiha ishtirokchilari (Topshiruvchi tanlovi).
  final List<ProjectMember> members;

  /// Ishtirokchilar yuklanmoqda (loyiha endi tanlandi).
  final bool membersLoading;

  final TaskSubmitStatus submitStatus;
  final Failure? submitFailure;

  /// Tahrirlanayotgan vazifa detali (faqat edit rejimida, prefill uchun).
  final TaskDetail? detail;
  final bool detailLoading;

  /// Vazifaga allaqachon biriktirilgan fayllar (edit rejimida).
  final List<TaskAttachmentInfo> attachments;

  final TaskStatusPermissionContext? permissionContext;

  TaskCreateState copyWith({
    List<Position>? positions,
    List<ProjectShort>? projects,
    List<ProjectMember>? members,
    bool? membersLoading,
    TaskSubmitStatus? submitStatus,
    Failure? submitFailure,
    TaskDetail? detail,
    bool? detailLoading,
    List<TaskAttachmentInfo>? attachments,
    TaskStatusPermissionContext? permissionContext,
  }) => TaskCreateState(
    positions: positions ?? this.positions,
    projects: projects ?? this.projects,
    members: members ?? this.members,
    membersLoading: membersLoading ?? this.membersLoading,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure ?? this.submitFailure,
    detail: detail ?? this.detail,
    detailLoading: detailLoading ?? this.detailLoading,
    attachments: attachments ?? this.attachments,
    permissionContext: permissionContext ?? this.permissionContext,
  );

  @override
  List<Object?> get props => [
    positions,
    projects,
    members,
    membersLoading,
    submitStatus,
    submitFailure,
    detail,
    detailLoading,
    attachments,
    permissionContext,
  ];
}
