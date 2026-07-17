import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../repository/users_repository.dart';

/// Bitta foydalanuvchi ma'lumotini olish (`GET /users/{id}/`).
class GetAppUserDetailUseCase implements UseCase<AppUser, int> {
  const GetAppUserDetailUseCase(this._repository);

  final UsersRepository _repository;

  @override
  Future<AppUser> call(int id) => _repository.getUser(id);
}
