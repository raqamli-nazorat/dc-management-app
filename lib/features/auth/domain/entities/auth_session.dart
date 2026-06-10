import 'package:equatable/equatable.dart';

import 'auth_tokens.dart';
import 'auth_user.dart';

/// Muvaffaqiyatli login natijasi: tokenlar + foydalanuvchi.
class AuthSession extends Equatable {
  const AuthSession({required this.tokens, required this.user});

  final AuthTokens tokens;
  final AuthUser user;

  @override
  List<Object?> get props => [tokens, user];
}
