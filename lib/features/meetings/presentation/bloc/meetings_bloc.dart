import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/usecases/get_meetings_usecase.dart';

part 'meetings_event.dart';
part 'meetings_state.dart';

/// Yig‘ilishlar ro‘yxati bloci (`GET /meetings/`).
class MeetingsBloc extends Bloc<MeetingsEvent, MeetingsState> {
  MeetingsBloc({required GetMeetingsUseCase getMeetings})
      : _getMeetings = getMeetings,
        super(const MeetingsState()) {
    on<MeetingsRequested>(_onRequested);
  }

  final GetMeetingsUseCase _getMeetings;

  Future<void> _onRequested(
    MeetingsRequested event,
    Emitter<MeetingsState> emit,
  ) async {
    emit(state.copyWith(status: MeetingsStatus.loading));
    try {
      final items = await _getMeetings(null);
      emit(state.copyWith(status: MeetingsStatus.success, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: MeetingsStatus.failure, failure: f));
    }
  }
}
