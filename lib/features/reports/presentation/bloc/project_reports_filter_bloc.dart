import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';

part 'project_reports_filter_event.dart';
part 'project_reports_filter_state.dart';

/// Loyiha hisobot filtri sahifasi bloci — foydalanuvchilar ro'yxatini
/// yuklaydi (Muallifi/Boshqaruvchi/Xodimlar/Sinovchilar — barchasi shu
/// ro'yxatdan ko'p-tanlov qiladi).
class ProjectReportsFilterBloc
    extends Bloc<ProjectReportsFilterEvent, ProjectReportsFilterState> {
  ProjectReportsFilterBloc({required GetUsersUseCase getUsers})
    : _getUsers = getUsers,
      super(const ProjectReportsFilterState()) {
    on<ProjectReportsFilterOptionsRequested>(_onRequested);
  }

  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    ProjectReportsFilterOptionsRequested event,
    Emitter<ProjectReportsFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final users = await _getUsers();
      emit(state.copyWith(loading: false, users: users));
    } catch (_) {
      // Yuklanmasa tanlov ro'yxatlari bo'sh qoladi.
      emit(state.copyWith(loading: false));
    }
  }
}
