part of 'pin_bloc.dart';

sealed class PinEvent extends Equatable {
  const PinEvent();

  @override
  List<Object?> get props => [];
}

/// Raqam bosildi (0–9).
class PinDigitPressed extends PinEvent {
  const PinDigitPressed(this.digit);

  final String digit;

  @override
  List<Object?> get props => [digit];
}

/// Oxirgi raqamni o‘chirish.
class PinBackspacePressed extends PinEvent {
  const PinBackspacePressed();
}

/// PIN-ni ko‘rsatish/yashirish.
class PinVisibilityToggled extends PinEvent {
  const PinVisibilityToggled();
}

/// To‘liq PIN terilganda yuboriladi (avtomatik).
class PinSubmitted extends PinEvent {
  const PinSubmitted();
}

/// Bloklash taymeri har soniyada (ichki).
class PinThrottleTicked extends PinEvent {
  const PinThrottleTicked();
}
