part of 'expense_request_create_bloc.dart';

sealed class ExpenseRequestCreateEvent extends Equatable {
  const ExpenseRequestCreateEvent();

  @override
  List<Object?> get props => [];
}

/// "So'rov yuborish" bosildi — tayyor [NewExpenseRequest] yuboriladi.
class ExpenseRequestCreateSubmitted extends ExpenseRequestCreateEvent {
  const ExpenseRequestCreateSubmitted(this.request);

  final NewExpenseRequest request;

  @override
  List<Object?> get props => [request];
}
