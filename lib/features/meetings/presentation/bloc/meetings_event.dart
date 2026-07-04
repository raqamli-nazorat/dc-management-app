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
