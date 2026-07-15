part of 'task_reports_bloc.dart';

enum TaskReportsStatus { initial, loading, success, failure }

class TaskReportsState extends Equatable {
  const TaskReportsState({
    this.status = TaskReportsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = TaskReportFilter.empty,
  });

  final TaskReportsStatus status;
  final List<TaskReport> items;
  final Failure? failure;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final TaskReportFilter filter;

  TaskReportsState copyWith({
    TaskReportsStatus? status,
    List<TaskReport>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    TaskReportFilter? filter,
  }) => TaskReportsState(
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
