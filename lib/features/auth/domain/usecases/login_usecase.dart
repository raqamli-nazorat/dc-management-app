import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../entities/auth_session.dart';
import '../repository/auth_repository.dart';

/// Login amal — bitta vazifa: foydalanuvchini tizimga kiritish.
class LoginUseCase implements UseCase<AuthSession, LoginParams> {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<AuthSession> call(LoginParams params) {
    return _repository.login(
      username: params.username,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  const LoginParams({required this.username, required this.password});

  final String username;
  final String password;

  @override
  List<Object?> get props => [username, password];
}
