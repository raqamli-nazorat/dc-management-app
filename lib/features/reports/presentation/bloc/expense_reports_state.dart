part of 'expense_reports_bloc.dart';

enum ExpenseReportsStatus { initial, loading, success, failure }

class ExpenseReportsState extends Equatable {
  const ExpenseReportsState({
    this.status = ExpenseReportsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = ExpenseReportFilter.empty,
  });

  final ExpenseReportsStatus status;
  final List<ExpenseReport> items;
  final Failure? failure;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final ExpenseReportFilter filter;

  ExpenseReportsState copyWith({
    ExpenseReportsStatus? status,
    List<ExpenseReport>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    ExpenseReportFilter? filter,
  }) => ExpenseReportsState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    filter: filter ?? this.filter,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    page,
    hasReachedMax,
    isLoadingMore,
    filter,
  ];
}
