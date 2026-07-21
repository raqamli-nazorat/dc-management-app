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

/// Tahrirlangan joriy profil maydonlarini saqlash.
class ProfileUpdateSubmitted extends ProfileEvent {
  const ProfileUpdateSubmitted(this.update);

  final ProfileUpdate update;

  @override
  List<Object?> get props => [update];
}
