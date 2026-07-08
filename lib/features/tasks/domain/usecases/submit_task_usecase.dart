import '../../../../core/usecases/usecase.dart';
import '../entities/new_task.dart';
import '../repository/task_repository.dart';

/// Vazifani yaratadi (`POST /tasks/`), so'ng qaytgan `id` ga fayllarni ketma-ket
/// biriktiradi (`POST /task-attachments/`). Yaratilgan vazifa `id`'sini qaytaradi.
class SubmitTaskUseCase implements UseCase<int, SubmitTaskParams> {
  const SubmitTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<int> call(SubmitTaskParams params) async {
    final id = await _repository.createTask(params.task);
    for (final path in params.filePaths) {
      await _repository.uploadAttachment(id, path);
    }
    return id;
  }
}

class SubmitTaskParams {
  const SubmitTaskParams({required this.task, this.filePaths = const []});

  final NewTask task;
  final List<String> filePaths;
}
