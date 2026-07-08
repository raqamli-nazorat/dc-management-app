import '../../../../core/usecases/usecase.dart';
import '../entities/task_form_options.dart';
import '../repository/task_repository.dart';

/// Vazifa formasi tanlov ro‘yxatlarini — lavozimlar + qisqa loyihalar — bir
/// martada parallel yuklaydi (ikkala so‘rov ham `await` dan oldin boshlanadi).
class GetTaskFormOptionsUseCase implements UseCase<TaskFormOptions, void> {
  const GetTaskFormOptionsUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<TaskFormOptions> call([void _]) async {
    final positions = _repository.getPositions();
    final projects = _repository.getProjectShorts();
    return (positions: await positions, projects: await projects);
  }
}
