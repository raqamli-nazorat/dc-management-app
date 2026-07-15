part of 'payroll_reports_bloc.dart';

sealed class PayrollReportsEvent extends Equatable {
  const PayrollReportsEvent();
  @override
  List<Object?> get props => [];
}

class PayrollReportsRequested extends PayrollReportsEvent {
  const PayrollReportsRequested();
}

class PayrollReportsLoadMore extends PayrollReportsEvent {
  const PayrollReportsLoadMore();
}

class PayrollReportsSearchChanged extends PayrollReportsEvent {
  const PayrollReportsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class PayrollReportsFilterChanged extends PayrollReportsEvent {
  const PayrollReportsFilterChanged(this.filter);
  final PayrollReportFilter filter;
  @override
  List<Object?> get props => [filter];
}
