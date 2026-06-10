part of 'login_bloc.dart';

sealed class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Login maydoni o‘zgardi.
class LoginUsernameChanged extends LoginEvent {
  const LoginUsernameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Parol maydoni o‘zgardi.
class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Parolni ko‘rsatish/yashirish.
class LoginObscureToggled extends LoginEvent {
  const LoginObscureToggled();
}

/// "Kirish" tugmasi bosildi.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}
