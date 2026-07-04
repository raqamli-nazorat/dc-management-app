import '../entities/profile.dart';

/// Profil domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class ProfileRepository {
  /// Joriy foydalanuvchi profilini oladi (`GET /users/me/`).
  Future<Profile> getMe();

  /// Profilni qisman yangilaydi (`PATCH /users/me/`).
  Future<Profile> updateMe(Map<String, dynamic> fields);

  /// Parolni almashtiradi (`PUT /users/me/change-password/`).
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}
