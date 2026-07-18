part of 'expense_request_options_bloc.dart';

class ExpenseRequestOptionsState extends Equatable {
  const ExpenseRequestOptionsState({this.loading = false, this.options});

  final bool loading;
  final ExpenseReportOptions? options;

  ExpenseRequestOptionsState copyWith({
    bool? loading,
    ExpenseReportOptions? options,
  }) => ExpenseRequestOptionsState(
    loading: loading ?? this.loading,
    options: options ?? this.options,
  );

  @override
  List<Object?> get props => [loading, options];
}
