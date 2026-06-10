part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.username = '',
    this.password = '',
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.accessToken,
    this.roles = const <String>[],
  });

  final String username;
  final String password;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;

  /// Muvaffaqiyatda sessiyaga uzatiladigan access token.
  final String? accessToken;

  /// Muvaffaqiyatda qaytgan rollar (rol tanlash oqimi uchun).
  final List<String> roles;

  bool get isLoading => status == LoginStatus.loading;

  bool get canSubmit =>
      username.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      status != LoginStatus.loading;

  LoginState copyWith({
    String? username,
    String? password,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? accessToken,
    List<String>? roles,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      accessToken: accessToken ?? this.accessToken,
      roles: roles ?? this.roles,
    );
  }

  @override
  List<Object?> get props => [
        username,
        password,
        obscurePassword,
        status,
        errorMessage,
        accessToken,
        roles,
      ];
}
