part of 'meetings_bloc.dart';

sealed class MeetingsEvent extends Equatable {
  const MeetingsEvent();

  @override
  List<Object?> get props => [];
}

/// Ro‘yxatni yuklash / qayta yuklash.
class MeetingsRequested extends MeetingsEvent {
  const MeetingsRequested();
}

/// Qidiruv matni o'zgardi - `GET /meetings/?search=...`.
class MeetingsSearchChanged extends MeetingsEvent {
  const MeetingsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
