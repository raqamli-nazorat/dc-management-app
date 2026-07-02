part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Joriy profilni yuklash (`GET /users/me/`).
class ProfileRequested extends ProfileEvent {
  const ProfileRequested();
}
