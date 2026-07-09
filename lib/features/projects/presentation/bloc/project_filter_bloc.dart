import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';

part 'project_filter_event.dart';
part 'project_filter_state.dart';

class ProjectFilterBloc extends Bloc<ProjectFilterEvent, ProjectFilterState> {
  ProjectFilterBloc({required GetUsersUseCase getUsers})
    : _getUsers = getUsers,
      super(const ProjectFilterState()) {
    on<ProjectFilterOptionsRequested>(_onRequested);
  }

  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    ProjectFilterOptionsRequested event,
    Emitter<ProjectFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final users = await _getUsers();
      emit(state.copyWith(loading: false, users: users));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}
