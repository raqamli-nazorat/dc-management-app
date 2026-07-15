part of 'expense_reports_bloc.dart';

sealed class ExpenseReportsEvent extends Equatable {
  const ExpenseReportsEvent();
  @override
  List<Object?> get props => [];
}

class ExpenseReportsRequested extends ExpenseReportsEvent {
  const ExpenseReportsRequested();
}

class ExpenseReportsLoadMore extends ExpenseReportsEvent {
  const ExpenseReportsLoadMore();
}

class ExpenseReportsSearchChanged extends ExpenseReportsEvent {
  const ExpenseReportsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class ExpenseReportsFilterChanged extends ExpenseReportsEvent {
  const ExpenseReportsFilterChanged(this.filter);
  final ExpenseReportFilter filter;
  @override
  List<Object?> get props => [filter];
}
