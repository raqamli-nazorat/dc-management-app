part of 'expense_requests_bloc.dart';

enum ExpenseRequestsStatus { initial, loading, success, failure }

class ExpenseRequestsState extends Equatable {
  const ExpenseRequestsState({
    this.status = ExpenseRequestsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = ExpenseRequestFilter.empty,
  });

  final ExpenseRequestsStatus status;
  final List<ExpenseRequest> items;
  final Failure? failure;

  /// Oxirgi muvaffaqiyatli yuklangan sahifa raqami.
  final int page;

  /// Keyingi sahifa yo'q (`next == null`) — load-more to'xtaydi.
  final bool hasReachedMax;

  /// Keyingi sahifa yuklanmoqda — footer spinner + qayta so'rov qulfi.
  final bool isLoadingMore;

  /// Joriy filtr (qidiruv matni ham shu ichida).
  final ExpenseRequestFilter filter;

  ExpenseRequestsState copyWith({
    ExpenseRequestsStatus? status,
    List<ExpenseRequest>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    ExpenseRequestFilter? filter,
  }) => ExpenseRequestsState(
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
