part of 'pin_bloc.dart';

enum PinStatus { input, loading, error, blocked, success }

/// Xato turi — lokalizatsiya UI qatlamida (bloc context'siz).
enum PinError { none, incorrect, blocked, network, generic }

class PinState extends Equatable {
  const PinState({
    this.length = defaultLength,
    this.pin = '',
    this.obscure = true,
    this.status = PinStatus.input,
    this.error = PinError.none,
    this.blockedSeconds = 0,
    this.roles = const <String>[],
    this.token,
  });

  /// Storage'da uzunlik bo‘lmasa — zaxira qiymat.
  static const int defaultLength = 6;

  /// PIN uzunligi — boshlang‘ich login parol uzunligidan (dinamik).
  final int length;
  final String pin;
  final bool obscure;
  final PinStatus status;
  final PinError error;
  final int blockedSeconds;

  /// Muvaffaqiyatda qaytgan rollar + token.
  final List<String> roles;
  final String? token;

  bool get isComplete => pin.length == length;
  bool get isBlocked => status == PinStatus.blocked;
  bool get isBusy => status == PinStatus.loading;

  PinState copyWith({
    int? length,
    String? pin,
    bool? obscure,
    PinStatus? status,
    PinError? error,
    int? blockedSeconds,
    List<String>? roles,
    String? token,
  }) {
    return PinState(
      length: length ?? this.length,
      pin: pin ?? this.pin,
      obscure: obscure ?? this.obscure,
      status: status ?? this.status,
      error: error ?? this.error,
      blockedSeconds: blockedSeconds ?? this.blockedSeconds,
      roles: roles ?? this.roles,
      token: token ?? this.token,
    );
  }

  @override
  List<Object?> get props =>
      [length, pin, obscure, status, error, blockedSeconds, roles, token];
}
