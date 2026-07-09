part of 'projects_bloc.dart';

enum ProjectsStatus { initial, loading, success, failure }

class ProjectsState extends Equatable {
  const ProjectsState({
    this.status = ProjectsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = ProjectFilter.empty,
    this.totalCount = 0,
  });

  final ProjectsStatus status;
  final List<Project> items;
  final Failure? failure;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final ProjectFilter filter;
  final int totalCount;

  ProjectsState copyWith({
    ProjectsStatus? status,
    List<Project>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    ProjectFilter? filter,
    int? totalCount,
  }) => ProjectsState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    page: page ?? this.page,
    hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    filter: filter ?? this.filter,
    totalCount: totalCount ?? this.totalCount,
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
    totalCount,
  ];
}
