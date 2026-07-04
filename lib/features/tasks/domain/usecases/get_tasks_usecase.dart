import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repository/task_repository.dart';

/// Vazifalar ro'yxatini olish (`GET /tasks/`).
class GetTasksUseCase implements UseCase<List<Task>, void> {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<List<Task>> call(void params) => _repository.getTasks();
}
