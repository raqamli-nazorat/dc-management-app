part of 'payroll_reports_bloc.dart';

enum PayrollReportsStatus { initial, loading, success, failure }

class PayrollReportsState extends Equatable {
  const PayrollReportsState({
    this.status = PayrollReportsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = PayrollReportFilter.empty,
  });

  final PayrollReportsStatus status;
  final List<PayrollReport> items;
  final Failure? failure;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final PayrollReportFilter filter;

  PayrollReportsState copyWith({
    PayrollReportsStatus? status,
    List<PayrollReport>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    PayrollReportFilter? filter,
  }) => PayrollReportsState(
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
