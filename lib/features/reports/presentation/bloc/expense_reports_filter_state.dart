part of 'expense_reports_filter_bloc.dart';

class ExpenseReportsFilterState extends Equatable {
  const ExpenseReportsFilterState({
    this.loading = false,
    this.options,
    this.users = const [],
  });
  final bool loading;
  final ExpenseReportOptions? options;
  final List<UserShort> users;

  ExpenseReportsFilterState copyWith({
    bool? loading,
    ExpenseReportOptions? options,
    List<UserShort>? users,
  }) => ExpenseReportsFilterState(
    loading: loading ?? this.loading,
    options: options ?? this.options,
    users: users ?? this.users,
  );

  @override
  List<Object?> get props => [loading, options, users];
}
