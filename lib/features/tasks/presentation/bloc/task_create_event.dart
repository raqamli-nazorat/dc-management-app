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
