part of 'meetings_bloc.dart';

enum MeetingsStatus { initial, loading, success, failure }

class MeetingsState extends Equatable {
  const MeetingsState({
    this.status = MeetingsStatus.initial,
    this.items = const [],
    this.filter = MeetingFilter.empty,
    this.failure,
  });

  final MeetingsStatus status;
  final List<Meeting> items;
  final MeetingFilter filter;
  final Failure? failure;

  MeetingsState copyWith({
    MeetingsStatus? status,
    List<Meeting>? items,
    MeetingFilter? filter,
    Failure? failure,
  }) => MeetingsState(
    status: status ?? this.status,
    items: items ?? this.items,
    filter: filter ?? this.filter,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, items, filter, failure];
}
