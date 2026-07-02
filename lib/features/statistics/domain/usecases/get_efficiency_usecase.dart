import '../../../../core/usecases/usecase.dart';
import '../entities/statistics.dart';
import '../repository/statistics_repository.dart';

/// Samaradorlik ko‘rsatkichlarini olish — `params` = tanlangan oylar soni.
class GetEfficiencyUseCase implements UseCase<EfficiencyStatistics, int> {
  const GetEfficiencyUseCase(this._repository);

  final StatisticsRepository _repository;

  @override
  Future<EfficiencyStatistics> call(int months) =>
      _repository.getEfficiency(months);
}
