import '../../../../core/usecases/usecase.dart';
import '../entities/task_form_options.dart';
import '../repository/task_repository.dart';

/// Lavozimlar ro'yxati kerak bo'lgan formalar uchun bitta tanlov so'rovi.
class GetPositionsUseCase implements UseCase<List<Position>, void> {
  const GetPositionsUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<List<Position>> call([void _]) => _repository.getPositions();
}
