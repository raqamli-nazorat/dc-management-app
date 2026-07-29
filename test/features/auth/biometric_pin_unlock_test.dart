import 'package:dc_management_app/app/bloc/session_bloc.dart';
import 'package:dc_management_app/core/constants/storage_keys.dart';
import 'package:dc_management_app/core/services/biometric_auth_service.dart';
import 'package:dc_management_app/core/services/storage_service.dart';
import 'package:dc_management_app/core/services/token_service.dart';
import 'package:dc_management_app/features/auth/domain/entities/auth_session.dart';
import 'package:dc_management_app/features/auth/domain/entities/auth_tokens.dart';
import 'package:dc_management_app/features/auth/domain/entities/auth_user.dart';
import 'package:dc_management_app/features/auth/domain/repository/auth_repository.dart';
import 'package:dc_management_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:dc_management_app/features/auth/presentation/pin/bloc/pin_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('available biometrics are exposed by PinBloc', () async {
    final bloc = _pinBloc(
      biometricAuth: _BiometricAuthFake(
        availability: BiometricAvailability.available,
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const PinBiometricAvailabilityChecked());

    final state = await bloc.stream.firstWhere(
      (state) => state.biometricAvailability == BiometricAvailability.available,
    );
    expect(state.biometricAvailability, BiometricAvailability.available);
  });

  test('successful biometric prompt emits a success result', () async {
    final bloc = _pinBloc(
      biometricAuth: _BiometricAuthFake(
        availability: BiometricAvailability.available,
        result: BiometricAuthResult.success,
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const PinBiometricAvailabilityChecked());
    await bloc.stream.firstWhere(
      (state) => state.biometricAvailability == BiometricAvailability.available,
    );
    bloc.add(const PinBiometricRequested('Confirm access'));

    final state = await bloc.stream.firstWhere(
      (state) => state.biometricResult == BiometricAuthResult.success,
    );
    expect(state.biometricPromptInProgress, isFalse);
    expect(state.error, PinError.none);
  });

  test('canceling biometric prompt keeps PIN fallback error-free', () async {
    final bloc = _pinBloc(
      biometricAuth: _BiometricAuthFake(
        availability: BiometricAvailability.available,
        result: BiometricAuthResult.userCanceled,
      ),
    );
    addTearDown(bloc.close);

    bloc.add(const PinBiometricAvailabilityChecked());
    await bloc.stream.firstWhere(
      (state) => state.biometricAvailability == BiometricAvailability.available,
    );
    bloc.add(const PinBiometricRequested('Confirm access'));

    final state = await bloc.stream.firstWhere(
      (state) => state.biometricResult == BiometricAuthResult.userCanceled,
    );
    expect(state.error, PinError.none);
    expect(state.biometricPromptInProgress, isFalse);
  });

  test('biometric unlock restores a saved-token session', () async {
    final storage = StorageService();
    final tokenService = TokenService(storage);
    await tokenService.saveToken('access-token');
    await storage.setString(StorageKeys.activeRole, 'employee');
    final bloc = SessionBloc(tokenService: tokenService, storage: storage);
    addTearDown(bloc.close);

    bloc.add(const SessionBiometricUnlocked());

    final state = await bloc.stream.firstWhere(
      (state) => state.isAuthenticated,
    );
    expect(state.activeRole, 'employee');
  });

  test('biometric unlock without a token requires login', () async {
    final storage = StorageService();
    final bloc = SessionBloc(
      tokenService: TokenService(storage),
      storage: storage,
    );
    addTearDown(bloc.close);

    bloc.add(const SessionBiometricUnlocked());

    final state = await bloc.stream.firstWhere(
      (state) => state.isUnauthenticated,
    );
    expect(state.status, SessionStatus.unauthenticated);
  });
}

PinBloc _pinBloc({required BiometricAuthService biometricAuth}) => PinBloc(
  loginUseCase: const LoginUseCase(_AuthRepositoryFake()),
  storage: StorageService(),
  biometricAuth: biometricAuth,
);

class _BiometricAuthFake extends BiometricAuthService {
  _BiometricAuthFake({
    this.availability = BiometricAvailability.unavailable,
    this.result = BiometricAuthResult.unavailable,
  });

  final BiometricAvailability availability;
  final BiometricAuthResult result;

  @override
  Future<BiometricAvailability> checkAvailability() async => availability;

  @override
  Future<BiometricAuthResult> authenticate(String localizedReason) async =>
      result;
}

class _AuthRepositoryFake implements AuthRepository {
  const _AuthRepositoryFake();

  @override
  Future<AuthSession> login({
    required String username,
    required String password,
  }) {
    return Future<AuthSession>.value(
      const AuthSession(
        tokens: AuthTokens(access: '', refresh: ''),
        user: AuthUser(id: 0, username: ''),
      ),
    );
  }

  @override
  Future<void> logout() async {}
}
