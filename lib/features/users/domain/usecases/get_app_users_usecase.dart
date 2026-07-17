import '../../../../core/usecases/usecase.dart';
import '../entities/app_user.dart';
import '../entities/users_filter.dart';
import '../repository/users_repository.dart';

/// [GetAppUsersUseCase] parametri: sahifa raqami + filtr.
typedef GetAppUsersParams = ({int page, UsersFilter filter});

/// Foydalanuvchilar ro'yxati sahifasini olish (`GET /users/`).
class GetAppUsersUseCase implements UseCase<AppUserPage, GetAppUsersParams> {
  const GetAppUsersUseCase(this._repository);

  final UsersRepository _repository;

  @override
  Future<AppUserPage> call(GetAppUsersParams params) =>
      _repository.getUsers(page: params.page, filter: params.filter);
}
