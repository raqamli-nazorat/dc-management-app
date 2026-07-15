import 'package:equatable/equatable.dart';

import '../../../tasks/domain/entities/task.dart';

/// Vazifa hisoboti filtri (`GET /reports/tasks/` query paramlari).
/// `priority`/`status` — bitta tanlov (dizayn bo'yicha), `type`/`sprint`/
/// `position` — API massiv qabul qilgani uchun ko'p-tanlov.
class TaskReportFilter extends Equatable {
  const TaskReportFilter({
    this.search = '',
    this.createdFrom,
    this.createdTo,
    this.projectIds = const {},
    this.assigneeIds = const {},
    this.authorIds = const {},
    this.priority,
    this.status,
    this.types = const {},
    this.sprints = const {},
    this.positionIds = const {},
    this.priceFrom,
    this.priceTo,
    this.penaltyFrom,
    this.penaltyTo,
    this.reopenedFrom,
    this.reopenedTo,
  });

  static const empty = TaskReportFilter();

  final String search;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final Set<int> projectIds;
  final Set<int> assigneeIds;
  final Set<int> authorIds;
  final TaskPriority? priority;
  final TaskStatus? status;
  final Set<TaskType> types;
  final Set<int> sprints;
  final Set<int> positionIds;
  final num? priceFrom;
  final num? priceTo;
  final num? penaltyFrom;
  final num? penaltyTo;
  final int? reopenedFrom;
  final int? reopenedTo;

  bool get hasActiveFilters =>
      createdFrom != null ||
      createdTo != null ||
      projectIds.isNotEmpty ||
      assigneeIds.isNotEmpty ||
      authorIds.isNotEmpty ||
      priority != null ||
      status != null ||
      types.isNotEmpty ||
      sprints.isNotEmpty ||
      positionIds.isNotEmpty ||
      priceFrom != null ||
      priceTo != null ||
      penaltyFrom != null ||
      penaltyTo != null ||
      reopenedFrom != null ||
      reopenedTo != null;

  TaskReportFilter copyWithSearch(String search) => TaskReportFilter(
    search: search,
    createdFrom: createdFrom,
    createdTo: createdTo,
    projectIds: projectIds,
    assigneeIds: assigneeIds,
    authorIds: authorIds,
    priority: priority,
    status: status,
    types: types,
    sprints: sprints,
    positionIds: positionIds,
    priceFrom: priceFrom,
    priceTo: priceTo,
    penaltyFrom: penaltyFrom,
    penaltyTo: penaltyTo,
    reopenedFrom: reopenedFrom,
    reopenedTo: reopenedTo,
  );

  @override
  List<Object?> get props => [
    search,
    createdFrom,
    createdTo,
    projectIds,
    assigneeIds,
    authorIds,
    priority,
    status,
    types,
    sprints,
    positionIds,
    priceFrom,
    priceTo,
    penaltyFrom,
    penaltyTo,
    reopenedFrom,
    reopenedTo,
  ];
}
