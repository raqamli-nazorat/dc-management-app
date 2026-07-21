import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../reports/domain/entities/user_report_filter.dart';
import '../../../reports/domain/usecases/get_districts_usecase.dart';
import '../../../reports/domain/usecases/get_regions_usecase.dart';
import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_positions_usecase.dart';
import '../../domain/entities/new_user.dart';
import '../../domain/usecases/create_app_user_usecase.dart';

part 'user_create_event.dart';
part 'user_create_state.dart';

/// Yangi foydalanuvchi formasi uchun tanlovlar va yuborish holati.
class UserCreateBloc extends Bloc<UserCreateEvent, UserCreateState> {
  UserCreateBloc({
    required GetPositionsUseCase getPositions,
    required GetRegionsUseCase getRegions,
    required GetDistrictsUseCase getDistricts,
    required CreateAppUserUseCase createUser,
  }) : _getPositions = getPositions,
       _getRegions = getRegions,
       _getDistricts = getDistricts,
       _createUser = createUser,
       super(const UserCreateState()) {
    on<UserCreateOptionsRequested>(_onOptionsRequested);
    on<UserCreateRegionSelected>(_onRegionSelected);
    on<UserCreateSubmitted>(_onSubmitted);
  }

  final GetPositionsUseCase _getPositions;
  final GetRegionsUseCase _getRegions;
  final GetDistrictsUseCase _getDistricts;
  final CreateAppUserUseCase _createUser;

  Future<void> _onOptionsRequested(
    UserCreateOptionsRequested event,
    Emitter<UserCreateState> emit,
  ) async {
    emit(state.copyWith(optionsLoading: true));
    try {
      final positions = _getPositions();
      final regions = _getRegions();
      emit(
        state.copyWith(
          optionsLoading: false,
          positions: await positions,
          regions: await regions,
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(optionsLoading: false, failure: failure));
    }
  }

  Future<void> _onRegionSelected(
    UserCreateRegionSelected event,
    Emitter<UserCreateState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedRegionId: event.regionId,
        districts: const [],
        districtsLoading: true,
      ),
    );
    try {
      final districts = await _getDistricts(event.regionId);
      if (state.selectedRegionId == event.regionId) {
        emit(state.copyWith(districtsLoading: false, districts: districts));
      }
    } on Failure catch (failure) {
      if (state.selectedRegionId == event.regionId) {
        emit(state.copyWith(districtsLoading: false, failure: failure));
      }
    }
  }

  Future<void> _onSubmitted(
    UserCreateSubmitted event,
    Emitter<UserCreateState> emit,
  ) async {
    if (state.submitting) return;
    emit(state.copyWith(submitting: true, clearFailure: true));
    try {
      await _createUser(event.user);
      emit(state.copyWith(submitting: false, success: true));
    } on Failure catch (failure) {
      emit(state.copyWith(submitting: false, failure: failure));
    }
  }
}
