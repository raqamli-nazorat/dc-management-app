import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repository/task_repository.dart';

/// Vazifalar sahifasini olish (`GET /tasks/?page=`). Param — sahifa raqami.
class GetTasksUseCase implements UseCase<TaskPage, int> {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<TaskPage> call(int page) => _repository.getTasks(page: page);
}
