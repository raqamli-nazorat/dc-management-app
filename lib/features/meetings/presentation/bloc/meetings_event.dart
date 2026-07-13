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

/// Filtr sahifasidan kelgan filter.
class MeetingsFilterChanged extends MeetingsEvent {
  const MeetingsFilterChanged(this.filter);

  final MeetingFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Qidiruv matni o'zgardi - `GET /meetings/?search=...`.
class MeetingsSearchChanged extends MeetingsEvent {
  const MeetingsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Yig'ilishni o'chirish (`DELETE /meetings/{id}/`) — optimistik: ro'yxatdan
/// darhol olib tashlanadi, xatoda qaytariladi.
class MeetingsMeetingDeleted extends MeetingsEvent {
  const MeetingsMeetingDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
