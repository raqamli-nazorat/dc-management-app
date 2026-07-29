import 'package:local_auth/local_auth.dart';

enum BiometricAvailability { available, notSupported, notEnrolled, unavailable }

enum BiometricAuthResult {
  success,
  userCanceled,
  failed,
  lockedOut,
  unavailable,
}

class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  final LocalAuthentication _localAuth;

  Future<BiometricAvailability> checkAvailability() async {
    try {
      if (!await _localAuth.isDeviceSupported() ||
          !await _localAuth.canCheckBiometrics) {
        return BiometricAvailability.notSupported;
      }
      return (await _localAuth.getAvailableBiometrics()).isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.noBiometricHardware =>
          BiometricAvailability.notSupported,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet =>
          BiometricAvailability.notEnrolled,
        _ => BiometricAvailability.unavailable,
      };
    } catch (_) {
      return BiometricAvailability.unavailable;
    }
  }

  Future<BiometricAuthResult> authenticate(String localizedReason) async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
      return authenticated
          ? BiometricAuthResult.success
          : BiometricAuthResult.userCanceled;
    } on LocalAuthException catch (error) {
      return switch (error.code) {
        LocalAuthExceptionCode.userCanceled ||
        LocalAuthExceptionCode.systemCanceled ||
        LocalAuthExceptionCode.timeout ||
        LocalAuthExceptionCode.userRequestedFallback =>
          BiometricAuthResult.userCanceled,
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthResult.lockedOut,
        LocalAuthExceptionCode.authInProgress ||
        LocalAuthExceptionCode.uiUnavailable ||
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthResult.unavailable,
        _ => BiometricAuthResult.failed,
      };
    } catch (_) {
      return BiometricAuthResult.unavailable;
    }
  }
}
