import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_task_form_options_usecase.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';
import '../../domain/entities/user_report_filter.dart';
import '../../domain/usecases/get_regions_usecase.dart';

part 'reports_filter_event.dart';
part 'reports_filter_state.dart';

/// Hisobot filtri sahifasi bloci — tanlov ro'yxatlarini (lavozimlar +
/// viloyatlar + foydalanuvchilar) parallel yuklaydi. Tanlovlarning o'zi
/// sahifa `State`ida.
class ReportsFilterBloc extends Bloc<ReportsFilterEvent, ReportsFilterState> {
  ReportsFilterBloc({
    required GetTaskFormOptionsUseCase getOptions,
    required GetUsersUseCase getUsers,
    required GetRegionsUseCase getRegions,
  }) : _getOptions = getOptions,
       _getUsers = getUsers,
       _getRegions = getRegions,
       super(const ReportsFilterState()) {
    on<ReportsFilterOptionsRequested>(_onRequested);
  }

  final GetTaskFormOptionsUseCase _getOptions;
  final GetUsersUseCase _getUsers;
  final GetRegionsUseCase _getRegions;

  Future<void> _onRequested(
    ReportsFilterOptionsRequested event,
    Emitter<ReportsFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final optionsFuture = _getOptions();
      final usersFuture = _getUsers();
      final regionsFuture = _getRegions();
      final options = await optionsFuture;
      final users = await usersFuture;
      final regions = await regionsFuture;
      emit(
        state.copyWith(
          loading: false,
          positions: options.positions,
          users: users,
          regions: regions,
        ),
      );
    } catch (_) {
      // Yuklanmasa dropdownlar bo'sh qoladi (statEmpty).
      emit(state.copyWith(loading: false));
    }
  }
}
