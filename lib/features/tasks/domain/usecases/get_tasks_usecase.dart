import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../entities/task_filter.dart';
import '../repository/task_repository.dart';

/// [GetTasksUseCase] parametri: sahifa raqami + filtr.
typedef GetTasksParams = ({int page, TaskFilter filter});

/// Vazifalar sahifasini olish (`GET /tasks/?page=` + filtr paramlari).
class GetTasksUseCase implements UseCase<TaskPage, GetTasksParams> {
  const GetTasksUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<TaskPage> call(GetTasksParams params) =>
      _repository.getTasks(page: params.page, filter: params.filter);
}
