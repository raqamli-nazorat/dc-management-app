import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';

part 'task_reports_filter_event.dart';
part 'task_reports_filter_state.dart';

/// Vazifa hisoboti filtri sahifasi bloci — tanlov ro'yxatlarini parallel
/// yuklaydi: lavozimlar + loyihalar ([GetTaskFormOptionsUseCase]) va
/// foydalanuvchilar ([GetUsersUseCase] — Topshiruvchilar/Muallif).
class TaskReportsFilterBloc
    extends Bloc<TaskReportsFilterEvent, TaskReportsFilterState> {
  TaskReportsFilterBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetUsersUseCase getUsers,
  }) : _getOptions = getOptions,
       _getUsers = getUsers,
       super(const TaskReportsFilterState()) {
    on<TaskReportsFilterOptionsRequested>(_onRequested);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    TaskReportsFilterOptionsRequested event,
    Emitter<TaskReportsFilterState> emit,
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
          positions: options.positions,
          projects: options.projects,
          users: users,
        ),
      );
    } catch (_) {
      // Yuklanmasa tanlov ro'yxatlari bo'sh qoladi (statEmpty).
      emit(state.copyWith(loading: false));
    }
  }
}
