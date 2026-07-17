import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';

part 'users_filter_event.dart';
part 'users_filter_state.dart';

/// Foydalanuvchilar filtri sahifasi bloci — lavozimlar tanlov ro'yxatini
/// yuklaydi ([GetTaskFormOptionsUseCase] — `ReportsFilterBloc` bilan bir xil
/// manba). Rollar ro'yxati statik (`RoleType`), yuklanmaydi.
class UsersFilterBloc extends Bloc<UsersFilterEvent, UsersFilterState> {
  UsersFilterBloc({required GetTaskFormOptionsUseCase getOptions})
    : _getOptions = getOptions,
      super(const UsersFilterState()) {
    on<UsersFilterOptionsRequested>(_onRequested);
  }

  final GetTaskFormOptionsUseCase _getOptions;

  Future<void> _onRequested(
    UsersFilterOptionsRequested event,
    Emitter<UsersFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final options = await _getOptions();
      emit(state.copyWith(loading: false, positions: options.positions));
    } catch (_) {
      // Yuklanmasa dropdown bo'sh qoladi (statEmpty).
      emit(state.copyWith(loading: false));
    }
  }
}
