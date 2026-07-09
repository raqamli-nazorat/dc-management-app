import '../../../../core/usecases/usecase.dart';
import '../entities/task_form_options.dart';
import '../repository/task_repository.dart';

class GetManagersUseCase implements UseCase<List<UserShort>, void> {
  const GetManagersUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<List<UserShort>> call([void _]) => _repository.getManagers();
}
