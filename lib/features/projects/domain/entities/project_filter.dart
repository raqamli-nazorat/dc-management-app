import 'package:equatable/equatable.dart';

import 'project.dart';

class ProjectFilter extends Equatable {
  const ProjectFilter({
    this.search = '',
    this.status,
    this.managerId,
    this.employeeId,
    this.deadlineFrom,
    this.deadlineTo,
    this.createdFrom,
    this.createdTo,
    this.isDeleted,
    this.ordering,
  });

  static const empty = ProjectFilter();

  final String search;
  final ProjectStatus? status;
  final int? managerId;
  final num? employeeId;
  final DateTime? deadlineFrom;
  final DateTime? deadlineTo;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final bool? isDeleted;
  final String? ordering;

  bool get hasActiveFilters =>
      status != null ||
      managerId != null ||
      employeeId != null ||
      deadlineFrom != null ||
      deadlineTo != null ||
      createdFrom != null ||
      createdTo != null ||
      isDeleted != null ||
      (ordering?.trim().isNotEmpty ?? false);

  ProjectFilter copyWith({
    String? search,
    ProjectStatus? status,
    int? managerId,
    num? employeeId,
    DateTime? deadlineFrom,
    DateTime? deadlineTo,
    DateTime? createdFrom,
    DateTime? createdTo,
    bool? isDeleted,
    String? ordering,
  }) => ProjectFilter(
    search: search ?? this.search,
    status: status ?? this.status,
    managerId: managerId ?? this.managerId,
    employeeId: employeeId ?? this.employeeId,
    deadlineFrom: deadlineFrom ?? this.deadlineFrom,
    deadlineTo: deadlineTo ?? this.deadlineTo,
    createdFrom: createdFrom ?? this.createdFrom,
    createdTo: createdTo ?? this.createdTo,
    isDeleted: isDeleted ?? this.isDeleted,
    ordering: ordering ?? this.ordering,
  );

  ProjectFilter copyWithStatus(ProjectStatus? status) => ProjectFilter(
    search: search,
    status: status,
    managerId: managerId,
    employeeId: employeeId,
    deadlineFrom: deadlineFrom,
    deadlineTo: deadlineTo,
    createdFrom: createdFrom,
    createdTo: createdTo,
    isDeleted: isDeleted,
    ordering: ordering,
  );

  @override
  List<Object?> get props => [
    search,
    status,
    managerId,
    employeeId,
    deadlineFrom,
    deadlineTo,
    createdFrom,
    createdTo,
    isDeleted,
    ordering,
  ];
}
