import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repository/task_repository.dart';

/// Vazifa holatini o'zgartiradi (`PATCH /tasks/{id}/change-status/`), rad
/// etishda sabab bilan birga tanlangan skrinshotlarni ham yuklaydi
/// (`POST /task-rejection-files/`).
class ChangeTaskStatusUseCase implements UseCase<void, ChangeTaskStatusParams> {
  const ChangeTaskStatusUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(ChangeTaskStatusParams params) async {
    await _repository.changeTaskStatus(
      params.id,
      params.status.apiValue!,
      reason: params.reason,
    );
    for (final path in params.photoPaths) {
      await _repository.uploadRejectionFile(params.id, path);
    }
  }
}

class ChangeTaskStatusParams {
  const ChangeTaskStatusParams({
    required this.id,
    required this.status,
    this.reason,
    this.photoPaths = const [],
  });

  final int id;
  final TaskStatus status;
  final String? reason;
  final List<String> photoPaths;
}
