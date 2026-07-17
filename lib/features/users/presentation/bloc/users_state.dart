part of 'users_bloc.dart';

enum UsersStatus { initial, loading, success, failure }

class UsersState extends Equatable {
  const UsersState({
    this.status = UsersStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = UsersFilter.empty,
  });

  final UsersStatus status;
  final List<AppUser> items;
  final Failure? failure;

  /// Oxirgi muvaffaqiyatli yuklangan sahifa raqami.
  final int page;

  /// Keyingi sahifa yo'q (`next == null`) — load-more to'xtaydi.
  final bool hasReachedMax;

  /// Keyingi sahifa yuklanmoqda — footer spinner + qayta so'rov qulfi.
  final bool isLoadingMore;

  /// Joriy filtr (qidiruv matni ham shu ichida).
  final UsersFilter filter;

  UsersState copyWith({
    UsersStatus? status,
    List<AppUser>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    UsersFilter? filter,
  }) => UsersState(
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
