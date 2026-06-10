import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_tokens.dart';
import 'auth_user_model.dart';

/// Login javobidagi `data` bloki: access + refresh + user.
class AuthSessionModel {
  const AuthSessionModel({
    required this.access,
    required this.refresh,
    required this.user,
  });

  final String access;
  final String refresh;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      access: json['access'] as String? ?? '',
      refresh: json['refresh'] as String? ?? '',
      user: AuthUserModel.fromJson(
        (json['user'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }

  AuthSession toEntity() => AuthSession(
        tokens: AuthTokens(access: access, refresh: refresh),
        user: user.toEntity(),
      );
}
