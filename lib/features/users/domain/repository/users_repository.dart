import '../entities/app_user.dart';
import '../entities/users_filter.dart';

/// Foydalanuvchilar domen shartnomasi. Implementatsiya `Exception`larni
/// `Failure`ga aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class UsersRepository {
  /// Bitta sahifa (`GET /users/?page=` + filtr paramlari).
  Future<AppUserPage> getUsers({int page, UsersFilter filter});

  /// Bitta foydalanuvchi (`GET /users/{id}/`).
  Future<AppUser> getUser(int id);
}
