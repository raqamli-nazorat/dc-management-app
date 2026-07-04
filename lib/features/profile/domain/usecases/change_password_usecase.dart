import '../../../../core/usecases/usecase.dart';
import '../repository/profile_repository.dart';

/// Parolni almashtirish uchun parametrlar.
class ChangePasswordParams {
  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmNewPassword;
}

/// Parolni almashtirish (`PUT /users/me/change-password/`).
class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  const ChangePasswordUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<void> call(ChangePasswordParams params) => _repository.changePassword(
        oldPassword: params.oldPassword,
        newPassword: params.newPassword,
        confirmNewPassword: params.confirmNewPassword,
      );
}
