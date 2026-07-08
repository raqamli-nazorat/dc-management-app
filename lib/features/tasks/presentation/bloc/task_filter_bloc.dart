import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/task_form_options.dart';
import '../../domain/usecases/get_task_form_options_usecase.dart';
import '../../domain/usecases/get_users_usecase.dart';

part 'task_filter_event.dart';
part 'task_filter_state.dart';

/// Filtr sahifasi bloci — tanlov ro'yxatlarini (loyihalar + lavozimlar +
/// foydalanuvchilar) parallel yuklaydi. Tanlovlarning o'zi sahifa `State`ida.
class TaskFilterBloc extends Bloc<TaskFilterEvent, TaskFilterState> {
  TaskFilterBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetUsersUseCase getUsers,
  }) : _getOptions = getOptions,
       _getUsers = getUsers,
       super(const TaskFilterState()) {
    on<TaskFilterOptionsRequested>(_onRequested);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    TaskFilterOptionsRequested event,
    Emitter<TaskFilterState> emit,
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
    } on Failure catch (_) {
      // Yuklanmasa dropdownlar bo'sh qoladi (statEmpty).
      emit(state.copyWith(loading: false));
    }
  }
}
