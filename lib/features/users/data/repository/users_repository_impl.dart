import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/users_filter.dart';
import '../../domain/repository/users_repository.dart';
import '../data_sources/users_remote_data_source.dart';

/// [UsersRepository] implementatsiyasi — data source `Exception`larini domen
/// `Failure`lariga aylantiradi.
class UsersRepositoryImpl implements UsersRepository {
  const UsersRepositoryImpl(this._remote);

  final UsersRemoteDataSource _remote;

  @override
  Future<AppUserPage> getUsers({
    int page = 1,
    UsersFilter filter = UsersFilter.empty,
  }) => _guard(() => _remote.getUsers(page: page, filter: filter));

  @override
  Future<AppUser> getUser(int id) => _guard(() => _remote.getUser(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
