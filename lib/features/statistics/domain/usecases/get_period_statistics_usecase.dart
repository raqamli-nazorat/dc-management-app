import '../../../../core/usecases/usecase.dart';
import '../entities/statistics.dart';
import '../repository/statistics_repository.dart';

/// Davr statistikasini olish — `params` = tanlangan oylar soni.
class GetPeriodStatisticsUseCase implements UseCase<PeriodStatistics, int> {
  const GetPeriodStatisticsUseCase(this._repository);

  final StatisticsRepository _repository;

  @override
  Future<PeriodStatistics> call(int months) =>
      _repository.getPeriodStatistics(months);
}
