import '../entities/auth_session.dart';

/// Auth domeni shartnomasi. Implementatsiya data qatlamida.
///
/// Xatolarda `Failure` (core/error/failures.dart) `throw` qiladi.
abstract interface class AuthRepository {
  /// Login/parol bilan kirish. Muvaffaqiyatda tokenlar + foydalanuvchini
  /// qaytaradi va lokal saqlaydi.
  Future<AuthSession> login({required String username, required String password});

  /// Joriy sessiyani tugatish — lokal tokenlarni tozalash.
  Future<void> logout();
}
