import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';

part 'meeting_filter_event.dart';
part 'meeting_filter_state.dart';

/// Meeting filter optionlari: tashkilotchilar (`users/all`) + loyihalar.
class MeetingFilterBloc extends Bloc<MeetingFilterEvent, MeetingFilterState> {
  MeetingFilterBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetUsersUseCase getUsers,
  }) : _getOptions = getOptions,
       _getUsers = getUsers,
       super(const MeetingFilterState()) {
    on<MeetingFilterOptionsRequested>(_onRequested);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    MeetingFilterOptionsRequested event,
    Emitter<MeetingFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final optionsFuture = _getOptions();
      final usersFuture = _getUsers();
      final options = await optionsFuture;
      final users = await usersFuture;
      emit(
        state.copyWith(
          loading: false,
          projects: options.projects,
          users: users,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}
