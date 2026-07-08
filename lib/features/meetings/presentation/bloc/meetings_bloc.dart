import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_filter.dart';
import '../../domain/usecases/get_meetings_usecase.dart';

part 'meetings_event.dart';
part 'meetings_state.dart';

/// Yig‘ilishlar ro‘yxati bloci (`GET /meetings/`).
class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  MeetingsBloc({required GetMeetingsUseCase getMeetings})
    : _getMeetings = getMeetings,
      super(const MeetingsState()) {
    on<MeetingsRequested>(_onRequested);
    on<MeetingsSearchChanged>(_onSearchChanged);
  }

  final GetMeetingsUseCase _getMeetings;

  Future<void> _onRequested(
    MeetingsRequested event,
    Emitter<MeetingsState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    MeetingsSearchChanged event,
    Emitter<MeetingsState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _reload(
    MeetingFilter filter,
    Emitter<MeetingsState> emit,
  ) async {
    emit(state.copyWith(status: MeetingsStatus.loading, filter: filter));
    try {
      final items = await _getMeetings(filter);
      emit(state.copyWith(status: MeetingsStatus.success, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: MeetingsStatus.failure, failure: f));
    }
  }
}
