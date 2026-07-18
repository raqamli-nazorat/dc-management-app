part of 'expense_request_options_bloc.dart';

sealed class ExpenseRequestOptionsEvent extends Equatable {
  const ExpenseRequestOptionsEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlov ro'yxatlarini yuklash (filtr sahifasi ochilganda).
class ExpenseRequestOptionsRequested extends ExpenseRequestOptionsEvent {
  const ExpenseRequestOptionsRequested();
}
