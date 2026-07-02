import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repository/profile_repository.dart';
import '../data_sources/profile_remote_data_source.dart';

/// [ProfileRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remote);

  final ProfileRemoteDataSource _remote;

  @override
  Future<Profile> getMe() => _guard(() => _remote.getMe());

  @override
  Future<Profile> updateMe(Map<String, dynamic> fields) =>
      _guard(() => _remote.updateMe(fields));

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      _guard(() => _remote.changePassword(
            oldPassword: oldPassword,
            newPassword: newPassword,
          ));

  /// Data source chaqiruvini o‘rab, `Exception` → `Failure` xaritalaydi.
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
