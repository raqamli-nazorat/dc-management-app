import '../../../../core/usecases/usecase.dart';
import '../entities/new_task.dart';
import '../repository/task_repository.dart';

/// Vazifani yangilaydi (`PATCH /tasks/{id}/`), so'ng belgilangan biriktirilgan
/// fayllarni o'chiradi va yangi tanlangan fayllarni biriktiradi.
class UpdateTaskUseCase implements UseCase<void, UpdateTaskParams> {
  const UpdateTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(UpdateTaskParams params) async {
    await _repository.updateTask(params.id, params.task);
    for (final attachmentId in params.removedAttachmentIds) {
      await _repository.deleteAttachment(attachmentId);
    }
    for (final path in params.filePaths) {
      await _repository.uploadAttachment(params.id, path);
    }
  }
}

class UpdateTaskParams {
  const UpdateTaskParams({
    required this.id,
    required this.task,
    this.removedAttachmentIds = const [],
    this.filePaths = const [],
  });

  final int id;
  final NewTask task;
  final List<int> removedAttachmentIds;
  final List<String> filePaths;
}
