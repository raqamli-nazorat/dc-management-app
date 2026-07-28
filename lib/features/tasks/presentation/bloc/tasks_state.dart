part of 'tasks_bloc.dart';

enum TasksStatus { initial, loading, success, failure }

class TaskStatusPageSnapshot extends Equatable {
  const TaskStatusPageSnapshot({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasReachedMax,
  });

  factory TaskStatusPageSnapshot.first(TaskPage page) => TaskStatusPageSnapshot(
    items: page.items,
    totalCount: page.totalCount,
    page: 1,
    hasReachedMax: !page.hasMore,
  );

  final List<Task> items;
  final int totalCount;
  final int page;
  final bool hasReachedMax;

  TaskStatusPageSnapshot append(TaskPage page) => TaskStatusPageSnapshot(
    items: [...items, ...page.items],
    totalCount: page.totalCount,
    page: this.page + 1,
    hasReachedMax: !page.hasMore,
  );

  TaskStatusPageSnapshot remove(int id) {
    final nextItems = items.where((t) => t.id != id).toList();
    final removed = nextItems.length != items.length;
    return TaskStatusPageSnapshot(
      items: nextItems,
      totalCount: removed && totalCount > 0 ? totalCount - 1 : totalCount,
      page: page,
      hasReachedMax: hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, page, hasReachedMax];
}

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = TaskFilter.empty,
    this.statusPages = const {},
    this.statusBaseFilter,
    this.deleteFailure,
    this.deleteFailureTick = 0,
  });

  final TasksStatus status;
  final List<Task> items;
  final Failure? failure;

  /// Oxirgi muvaffaqiyatli yuklangan sahifa raqami.
  final int page;

  /// Keyingi sahifa yo'q (`next == null`) — load-more to'xtaydi.
  final bool hasReachedMax;

  /// Keyingi sahifa yuklanmoqda — footer spinner + qayta so'rov qulfi.
  final bool isLoadingMore;

  /// Joriy filtr (Loyiha/Muallif/Xodim/Daraja/Turi/Topshiruvchi/muddat + qidiruv).
  final TaskFilter filter;

  /// Har bir status uchun birinchi sahifa + count cache.
  final Map<TaskStatus, TaskStatusPageSnapshot> statusPages;

  /// [statusPages] qaysi statussiz filter uchun olingan.
  final TaskFilter? statusBaseFilter;

  /// Oxirgi delete xatosi — UI toast chiqarishi uchun.
  final Failure? deleteFailure;

  /// Bir xil xabar ketma-ket kelsa ham listener ishlashi uchun.
  final int deleteFailureTick;

  Map<TaskStatus, int> get statusCounts => {
    for (final entry in statusPages.entries) entry.key: entry.value.totalCount,
  };

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    TaskFilter? filter,
    Map<TaskStatus, TaskStatusPageSnapshot>? statusPages,
    TaskFilter? statusBaseFilter,
    Failure? deleteFailure,
    int? deleteFailureTick,
    bool clearStatusBaseFilter = false,
  }) => TasksState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    filter: filter ?? this.filter,
    statusPages: statusPages ?? this.statusPages,
    statusBaseFilter: clearStatusBaseFilter
        ? null
        : statusBaseFilter ?? this.statusBaseFilter,
    deleteFailure: deleteFailure,
    deleteFailureTick: deleteFailureTick ?? this.deleteFailureTick,
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
    statusPages,
    statusBaseFilter,
    deleteFailure,
    deleteFailureTick,
  ];
}
