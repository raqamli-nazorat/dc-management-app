part of 'statistics_bloc.dart';

sealed class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

/// Joriy davr bo‘yicha statistikani yuklash (birinchi kirish / qayta urinish).
class StatisticsRequested extends StatisticsEvent {
  const StatisticsRequested();
}

/// Davr segment tanlovi o‘zgardi (1 oy / 3 oy / 6 oy / 1 yil).
class StatisticsPeriodChanged extends StatisticsEvent {
  const StatisticsPeriodChanged(this.period);

  final StatPeriod period;

  @override
  List<Object?> get props => [period];
}
