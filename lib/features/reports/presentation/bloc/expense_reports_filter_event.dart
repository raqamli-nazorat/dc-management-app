part of 'expense_reports_filter_bloc.dart';

sealed class ExpenseReportsFilterEvent extends Equatable {
  const ExpenseReportsFilterEvent();
  @override
  List<Object?> get props => [];
}

class ExpenseReportsFilterOptionsRequested extends ExpenseReportsFilterEvent {
  const ExpenseReportsFilterOptionsRequested();
}
