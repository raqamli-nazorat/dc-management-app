part of 'user_create_bloc.dart';

sealed class UserCreateEvent extends Equatable {
  const UserCreateEvent();

  @override
  List<Object?> get props => [];
}

class UserCreateOptionsRequested extends UserCreateEvent {
  const UserCreateOptionsRequested();
}

class UserCreateRegionSelected extends UserCreateEvent {
  const UserCreateRegionSelected(this.regionId);

  final int regionId;

  @override
  List<Object?> get props => [regionId];
}

class UserCreateSubmitted extends UserCreateEvent {
  const UserCreateSubmitted(this.user);

  final NewUser user;

  @override
  List<Object?> get props => [user];
}
