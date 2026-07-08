part of 'tasks_bloc.dart';

enum TasksStatus { initial, loading, success, failure }

class TasksState extends Equatable {
  const TasksState({
    this.status = TasksStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = TaskFilter.empty,
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

  TasksState copyWith({
    TasksStatus? status,
    List<Task>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    TaskFilter? filter,
  }) => TasksState(
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
