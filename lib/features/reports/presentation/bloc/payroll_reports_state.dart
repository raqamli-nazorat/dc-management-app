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
    this.search = '',
  });

  final PayrollReportsStatus status;
  final List<PayrollReport> items;
  final Failure? failure;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String search;

  PayrollReportsState copyWith({
    PayrollReportsStatus? status,
    List<PayrollReport>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? search,
  }) => PayrollReportsState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    search: search ?? this.search,
  );

  @override
  List<Object?> get props => [
    status,
    items,
    failure,
    page,
    hasReachedMax,
    isLoadingMore,
    search,
  ];
}
