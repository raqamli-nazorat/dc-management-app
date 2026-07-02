import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/usecases/get_efficiency_usecase.dart';
import '../../domain/usecases/get_period_statistics_usecase.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

/// Bosh sahifa statistikasi bloci — davr statistikasi + samaradorlikni
/// tanlangan davr ([StatPeriod]) bo‘yicha yuklaydi.
class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc({
    required GetPeriodStatisticsUseCase getPeriod,
    required GetEfficiencyUseCase getEfficiency,
  })  : _getPeriod = getPeriod,
        _getEfficiency = getEfficiency,
        super(const StatisticsState()) {
    on<StatisticsRequested>(_onRequested);
    on<StatisticsPeriodChanged>(_onPeriodChanged);
  }

  final GetPeriodStatisticsUseCase _getPeriod;
  final GetEfficiencyUseCase _getEfficiency;

  Future<void> _onRequested(
    StatisticsRequested event,
    Emitter<StatisticsState> emit,
  ) =>
      _load(state.period, emit);

  Future<void> _onPeriodChanged(
    StatisticsPeriodChanged event,
    Emitter<StatisticsState> emit,
  ) {
    if (event.period == state.period &&
        state.status == StatisticsStatus.success) {
      return Future.value();
    }
    emit(state.copyWith(period: event.period));
    return _load(event.period, emit);
  }

  Future<void> _load(StatPeriod period, Emitter<StatisticsState> emit) async {
    emit(state.copyWith(status: StatisticsStatus.loading));
    try {
      // Ikkala so‘rov parallel — bir-biriga bog‘liq emas.
      final results = await Future.wait([
        _getPeriod(period.months),
        _getEfficiency(period.months),
      ]);
      emit(state.copyWith(
        status: StatisticsStatus.success,
        period: period,
        periodStatistics: results[0] as PeriodStatistics,
        efficiency: results[1] as EfficiencyStatistics,
      ));
    } on Failure catch (f) {
      emit(state.copyWith(status: StatisticsStatus.failure, failure: f));
    }
  }
}
