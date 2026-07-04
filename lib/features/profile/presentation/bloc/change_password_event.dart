part of 'change_password_bloc.dart';

sealed class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchi parolni almashtirishni tasdiqladi — eski + yangi + tasdiq
/// parolni backendga yuborish.
class ChangePasswordSubmitted extends ChangePasswordEvent {
  const ChangePasswordSubmitted({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmNewPassword;

  @override
  List<Object?> get props => [oldPassword, newPassword, confirmNewPassword];
}
