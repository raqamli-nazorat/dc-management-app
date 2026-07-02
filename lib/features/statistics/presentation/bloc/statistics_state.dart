part of 'statistics_bloc.dart';

enum StatisticsStatus { initial, loading, success, failure }

/// Grafiklar davri — segment selektori qiymatlari. [months] backend so‘roviga
/// (`?months=`) uzatiladi.
enum StatPeriod {
  month1(1),
  month3(3),
  month6(6),
  year1(12);

  const StatPeriod(this.months);

  final int months;
}

class StatisticsState extends Equatable {
  const StatisticsState({
    this.status = StatisticsStatus.initial,
    this.period = StatPeriod.month1,
    this.periodStatistics,
    this.efficiency,
    this.failure,
  });

  final StatisticsStatus status;
  final StatPeriod period;
  final PeriodStatistics? periodStatistics;
  final EfficiencyStatistics? efficiency;
  final Failure? failure;

  /// Kamida bir marta muvaffaqiyatli yuklangan (grafiklar chizishga tayyor).
  bool get hasData => periodStatistics != null;

  StatisticsState copyWith({
    StatisticsStatus? status,
    StatPeriod? period,
    PeriodStatistics? periodStatistics,
    EfficiencyStatistics? efficiency,
    Failure? failure,
  }) =>
      StatisticsState(
        status: status ?? this.status,
        period: period ?? this.period,
        periodStatistics: periodStatistics ?? this.periodStatistics,
        efficiency: efficiency ?? this.efficiency,
        failure: failure,
      );

  @override
  List<Object?> get props => [
        status,
        period,
        periodStatistics,
        efficiency,
        failure,
      ];
}
