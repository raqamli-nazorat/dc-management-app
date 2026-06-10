import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/storage_keys.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/services/storage_service.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/usecases/login_usecase.dart';

part 'pin_event.dart';
part 'pin_state.dart';

/// PIN avtorizatsiya oqimini boshqaruvchi alohida BLoC moduli.
///
/// PIN = parol: to‘liq 6 raqam terilganda keshlangan login identifikatori bilan
/// Login API’ga so‘rov yuboriladi. 429 (throttle) javobida `errorMsg`dan qolgan
/// soniyalar ajratib olinib, bloklash taymeri ishga tushadi.
class PinBloc extends Bloc<PinEvent, PinState> {
  PinBloc({
    required LoginUseCase loginUseCase,
    required StorageService storage,
  })  : _loginUseCase = loginUseCase,
        _storage = storage,
        super(PinState(length: _readLength(storage))) {
    on<PinDigitPressed>(_onDigitPressed);
    on<PinBackspacePressed>(_onBackspace);
    on<PinVisibilityToggled>(_onVisibilityToggled);
    on<PinSubmitted>(_onSubmitted);
    on<PinThrottleTicked>(_onThrottleTicked);
  }

  final LoginUseCase _loginUseCase;
  final StorageService _storage;

  Timer? _throttleTimer;

  static final RegExp _secondsRegExp = RegExp(r'(\d+)\s*second');

  /// Saqlangan parol uzunligini o‘qiydi (dinamik PIN slotlari soni).
  static int _readLength(StorageService storage) {
    final raw = storage.getString(StorageKeys.pinLength);
    final parsed = int.tryParse(raw ?? '');
    if (parsed == null || parsed <= 0) return PinState.defaultLength;
    return parsed;
  }

  void _onDigitPressed(PinDigitPressed event, Emitter<PinState> emit) {
    if (state.isBusy || state.isBlocked) return;
    if (state.pin.length >= state.length) return;

    final pin = state.pin + event.digit;
    emit(state.copyWith(
      pin: pin,
      status: PinStatus.input,
      error: PinError.none,
    ));

    if (pin.length == state.length) {
      add(const PinSubmitted());
    }
  }

  void _onBackspace(PinBackspacePressed event, Emitter<PinState> emit) {
    if (state.isBusy || state.isBlocked || state.pin.isEmpty) return;
    emit(state.copyWith(
      pin: state.pin.substring(0, state.pin.length - 1),
      status: PinStatus.input,
      error: PinError.none,
    ));
  }

  void _onVisibilityToggled(
    PinVisibilityToggled event,
    Emitter<PinState> emit,
  ) {
    emit(state.copyWith(obscure: !state.obscure));
  }

  Future<void> _onSubmitted(PinSubmitted event, Emitter<PinState> emit) async {
    if (!state.isComplete) return;

    final username = _storage.getString(StorageKeys.loginUsername);
    if (username == null || username.isEmpty) {
      emit(state.copyWith(status: PinStatus.error, error: PinError.generic));
      return;
    }

    emit(state.copyWith(status: PinStatus.loading, error: PinError.none));
    try {
      final AuthSession session = await _loginUseCase(
        LoginParams(username: username, password: state.pin),
      );
      emit(state.copyWith(
        status: PinStatus.success,
        roles: session.user.roles,
        token: session.tokens.access,
      ));
    } on ThrottleFailure catch (failure) {
      _startThrottle(_parseSeconds(failure.message), emit);
    } on UnauthorizedFailure catch (_) {
      emit(state.copyWith(
        pin: '',
        status: PinStatus.error,
        error: PinError.incorrect,
      ));
    } on NetworkFailure catch (_) {
      emit(state.copyWith(
        pin: '',
        status: PinStatus.error,
        error: PinError.network,
      ));
    } on Failure catch (_) {
      emit(state.copyWith(
        pin: '',
        status: PinStatus.error,
        error: PinError.generic,
      ));
    } catch (_) {
      emit(state.copyWith(
        pin: '',
        status: PinStatus.error,
        error: PinError.generic,
      ));
    }
  }

  void _onThrottleTicked(PinThrottleTicked event, Emitter<PinState> emit) {
    final remaining = state.blockedSeconds - 1;
    if (remaining <= 0) {
      _throttleTimer?.cancel();
      emit(state.copyWith(
        status: PinStatus.input,
        error: PinError.none,
        blockedSeconds: 0,
      ));
      return;
    }
    emit(state.copyWith(blockedSeconds: remaining));
  }

  void _startThrottle(int seconds, Emitter<PinState> emit) {
    final total = seconds <= 0 ? 1 : seconds;
    emit(state.copyWith(
      pin: '',
      status: PinStatus.blocked,
      error: PinError.blocked,
      blockedSeconds: total,
    ));
    _throttleTimer?.cancel();
    _throttleTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const PinThrottleTicked()),
    );
  }

  int _parseSeconds(String message) {
    final match = _secondsRegExp.firstMatch(message);
    if (match == null) return 0;
    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  @override
  Future<void> close() {
    _throttleTimer?.cancel();
    return super.close();
  }
}
