import '../entities/statistics.dart';

/// Statistika domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class StatisticsRepository {
  /// Davr statistikasi (`GET /users/me/period-statistics/?months=`).
  Future<PeriodStatistics> getPeriodStatistics(int months);
}
