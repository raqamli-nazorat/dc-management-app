import '../../../../core/usecases/usecase.dart';
import '../entities/task_form_options.dart';
import '../repository/task_repository.dart';

/// Barcha foydalanuvchilar ro'yxatini oladi (`GET /users/all/`) — filtrdagi
/// "Muallif" va "Xodim" tanlovlari uchun.
class GetUsersUseCase implements UseCase<List<UserShort>, void> {
  const GetUsersUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<List<UserShort>> call([void _]) => _repository.getUsers();
}
