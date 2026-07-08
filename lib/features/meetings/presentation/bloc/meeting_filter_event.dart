part of 'meeting_filter_bloc.dart';

sealed class MeetingFilterEvent extends Equatable {
  const MeetingFilterEvent();

  @override
  List<Object?> get props => [];
}

class MeetingFilterOptionsRequested extends MeetingFilterEvent {
  const MeetingFilterOptionsRequested();
}
