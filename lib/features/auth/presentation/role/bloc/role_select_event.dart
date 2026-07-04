part of 'role_select_bloc.dart';

sealed class RoleSelectEvent extends Equatable {
  const RoleSelectEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchi rolni tanladi — backendga yozib faol rolni almashtirish.
class RoleSelectSubmitted extends RoleSelectEvent {
  const RoleSelectSubmitted(this.role);

  final String role;

  @override
  List<Object?> get props => [role];
}
