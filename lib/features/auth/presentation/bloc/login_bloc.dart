import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/error_messages.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Login ekrani holatini boshqaradi (events → states).
///
/// Muvaffaqiyatda [LoginStatus.success] + access token emit qiladi; navigatsiya
/// `SessionBloc` orqali sahifadagi listener tomonidan bajariladi — bloc toza
/// (navigatsiyaga bog‘liq emas).
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(const LoginState()) {
    on<LoginUsernameChanged>(_onUsernameChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginObscureToggled>(_onObscureToggled);
    on<LoginSubmitted>(_onSubmitted);
  }

  final LoginUseCase _loginUseCase;

  void _onUsernameChanged(LoginUsernameChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      username: event.value,
      status: LoginStatus.initial,
      clearError: true,
    ));
  }

  void _onPasswordChanged(LoginPasswordChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(
      password: event.value,
      status: LoginStatus.initial,
      clearError: true,
    ));
  }

  void _onObscureToggled(LoginObscureToggled event, Emitter<LoginState> emit) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: LoginStatus.loading, clearError: true));
    try {
      final AuthSession session = await _loginUseCase(
        LoginParams(
          username: state.username.trim(),
          password: state.password,
        ),
      );
      emit(state.copyWith(
        status: LoginStatus.success,
        accessToken: session.tokens.access,
        roles: session.user.roles,
      ));
    } on Failure catch (failure) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: _mapFailure(failure),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: LoginStatus.failure,
        errorMessage: ErrorMessages.unknown,
      ));
    }
  }

  String _mapFailure(Failure failure) {
    return switch (failure) {
      UnauthorizedFailure() => ErrorMessages.invalidCredentials,
      NetworkFailure() => ErrorMessages.network,
      // Throttle/server — backend xabari foydalanuvchiga tushunarli (isFriendly).
      _ => failure.message,
    };
  }
}
