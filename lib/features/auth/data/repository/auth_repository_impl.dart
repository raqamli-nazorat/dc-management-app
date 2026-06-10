import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/token_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repository/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

/// [AuthRepository] implementatsiyasi.
///
/// Data source `Exception`larini domen `Failure`lariga aylantiradi va
/// muvaffaqiyatda tokenlar + foydalanuvchini lokal saqlaydi.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required TokenService tokenService,
    required StorageService storage,
  })  : _remote = remote,
        _tokenService = tokenService,
        _storage = storage;

  final AuthRemoteDataSource _remote;
  final TokenService _tokenService;
  final StorageService _storage;

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) async {
    try {
      final model = await _remote.login(username: username, password: password);

      // Lokal saqlash — keyingi so‘rovlar va refresh uchun.
      await _tokenService.saveToken(model.access);
      await _tokenService.saveRefreshToken(model.refresh);
      await _storage.setString(
        StorageKeys.cachedUser,
        jsonEncode(model.user.toJson()),
      );
      // Login identifikatorini keshlash — PIN oqimi shu username bilan
      // qayta autentifikatsiya qiladi (PIN = parol).
      await _storage.setString(StorageKeys.loginUsername, username);
      // Parol uzunligini saqlash — PIN ko‘rsatkichi slotlari soni shunga teng.
      await _storage.setString(
        StorageKeys.pinLength,
        password.length.toString(),
      );

      return model.toEntity();
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

  @override
  Future<void> logout() async {
    await _tokenService.clearAll();
    await _storage.remove(StorageKeys.cachedUser);
  }
}
