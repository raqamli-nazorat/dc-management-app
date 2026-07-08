import '../../../../core/usecases/usecase.dart';
import '../repository/task_repository.dart';

/// Vazifani o'chiradi (`DELETE /tasks/{id}/`). Param — vazifa `id`'si.
class DeleteTaskUseCase implements UseCase<void, int> {
  const DeleteTaskUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<void> call(int id) => _repository.deleteTask(id);
}
