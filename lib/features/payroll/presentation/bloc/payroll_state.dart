part of 'payroll_bloc.dart';

enum PayrollStatus { initial, loading, success, failure }

class PayrollState extends Equatable {
  const PayrollState({
    this.status = PayrollStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.search = '',
  });

  final PayrollStatus status;
  final List<Payroll> items;
  final Failure? failure;

  /// Oxirgi muvaffaqiyatli yuklangan sahifa raqami.
  final int page;

  /// Keyingi sahifa yo'q (`next == null`) — load-more to'xtaydi.
  final bool hasReachedMax;

  /// Keyingi sahifa yuklanmoqda — footer spinner + qayta so'rov qulfi.
  final bool isLoadingMore;

  /// Joriy qidiruv matni.
  final String search;

  PayrollState copyWith({
    PayrollStatus? status,
    List<Payroll>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? search,
  }) => PayrollState(
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
