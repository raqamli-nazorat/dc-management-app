part of 'task_create_bloc.dart';

sealed class TaskCreateEvent extends Equatable {
  const TaskCreateEvent();

  @override
  List<Object?> get props => [];
}

/// Forma tanlov ro'yxatlarini (lavozimlar + loyihalar) yuklash.
class TaskCreateOptionsRequested extends TaskCreateEvent {
  const TaskCreateOptionsRequested();
}

/// Loyiha tanlandi — o'sha loyiha ishtirokchilarini (Topshiruvchi) yuklash.
class TaskCreateProjectSelected extends TaskCreateEvent {
  const TaskCreateProjectSelected(this.projectId);

  final int projectId;

  @override
  List<Object?> get props => [projectId];
}

/// Formani yuborish: vazifa yaratish + fayllarni biriktirish.
class TaskCreateSubmitted extends TaskCreateEvent {
  const TaskCreateSubmitted(this.params);

  final SubmitTaskParams params;

  @override
  List<Object?> get props => [params.task, params.filePaths];
}

/// Tahrirlash: vazifa detali + biriktirilgan fayllarni yuklash (prefill).
class TaskCreateDetailRequested extends TaskCreateEvent {
  const TaskCreateDetailRequested(this.taskId);

  final int taskId;

  @override
  List<Object?> get props => [taskId];
}

/// Batafsil: holatni o'zgartirish (tekshirildi / rad etildi / bajarildi).
class TaskCreateStatusSubmitted extends TaskCreateEvent {
  const TaskCreateStatusSubmitted(this.params);

  final ChangeTaskStatusParams params;

  @override
  List<Object?> get props => [
    params.id,
    params.status,
    params.reason,
    params.photoPaths,
  ];
}

/// Tahrirlashni yuborish: PATCH + fayl o'chirish/qo'shish.
class TaskCreateUpdateSubmitted extends TaskCreateEvent {
  const TaskCreateUpdateSubmitted(this.params);

  final UpdateTaskParams params;

  @override
  List<Object?> get props => [
    params.id,
    params.task,
    params.removedAttachmentIds,
    params.filePaths,
  ];
}
