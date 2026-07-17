part of 'users_filter_bloc.dart';

sealed class UsersFilterEvent extends Equatable {
  const UsersFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlov ro'yxatlarini yuklash (sahifa ochilganda bir marta).
class UsersFilterOptionsRequested extends UsersFilterEvent {
  const UsersFilterOptionsRequested();
}
