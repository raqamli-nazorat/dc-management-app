import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repository/statistics_repository.dart';
import '../data_sources/statistics_remote_data_source.dart';

/// [StatisticsRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl(this._remote);

  final StatisticsRemoteDataSource _remote;

  @override
  Future<PeriodStatistics> getPeriodStatistics(int months) =>
      _guard(() => _remote.getPeriodStatistics(months));

  @override
  Future<EfficiencyStatistics> getEfficiency(int months) =>
      _guard(() => _remote.getEfficiency(months));

  /// Data source chaqiruvini o‘rab, `Exception` → `Failure` xaritalaydi.
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
