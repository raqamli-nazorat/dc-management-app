import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../entities/new_user.dart';
import '../repository/users_repository.dart';

/// Yangi foydalanuvchi yaratadi (`POST /users/`).
class CreateAppUserUseCase implements UseCase<AppUser, NewUser> {
  const CreateAppUserUseCase(this._repository);

  final UsersRepository _repository;

  @override
  Future<AppUser> call(NewUser user) => _repository.createUser(user);
}
