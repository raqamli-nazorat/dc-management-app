part of 'project_reports_bloc.dart';

enum ProjectReportsStatus { initial, loading, success, failure }

class ProjectReportsState extends Equatable {
  const ProjectReportsState({
    this.status = ProjectReportsStatus.initial,
    this.items = const [],
    this.failure,
    this.page = 1,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.filter = ProjectReportFilter.empty,
  });

  final ProjectReportsStatus status;
  final List<ProjectReport> items;
  final Failure? failure;

  /// Oxirgi muvaffaqiyatli yuklangan sahifa raqami.
  final int page;

  /// Keyingi sahifa yo'q (`next == null`) — load-more to'xtaydi.
  final bool hasReachedMax;

  /// Keyingi sahifa yuklanmoqda — footer spinner + qayta so'rov qulfi.
  final bool isLoadingMore;

  /// Joriy filtr (qidiruv matni ham shu ichida).
  final ProjectReportFilter filter;

  ProjectReportsState copyWith({
    ProjectReportsStatus? status,
    List<ProjectReport>? items,
    Failure? failure,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    ProjectReportFilter? filter,
  }) => ProjectReportsState(
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
