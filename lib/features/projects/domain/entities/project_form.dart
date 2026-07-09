import 'package:equatable/equatable.dart';

import 'project.dart';

class ProjectForm extends Equatable {
  const ProjectForm({
    required this.prefix,
    required this.title,
    required this.manager,
    required this.deadline,
    this.description,
    this.testers = const [],
    this.employees = const [],
    this.projectPrice,
    this.penaltyPercentage,
    this.status,
    this.isHidden,
  });

  final String prefix;
  final String title;
  final String? description;
  final int manager;
  final List<int> testers;
  final List<int> employees;
  final DateTime deadline;
  final String? projectPrice;
  final String? penaltyPercentage;
  final ProjectStatus? status;
  final bool? isHidden;

  @override
  List<Object?> get props => [
    prefix,
    title,
    description,
    manager,
    testers,
    employees,
    deadline,
    projectPrice,
    penaltyPercentage,
    status,
    isHidden,
  ];
}

class ProjectPatch extends Equatable {
  const ProjectPatch({
    this.prefix,
    this.title,
    this.description,
    this.manager,
    this.testers,
    this.employees,
    this.deadline,
    this.projectPrice,
    this.penaltyPercentage,
    this.status,
    this.isHidden,
  });

  final String? prefix;
  final String? title;
  final String? description;
  final int? manager;
  final List<int>? testers;
  final List<int>? employees;
  final DateTime? deadline;
  final String? projectPrice;
  final String? penaltyPercentage;
  final ProjectStatus? status;
  final bool? isHidden;

  @override
  List<Object?> get props => [
    prefix,
    title,
    description,
    manager,
    testers,
    employees,
    deadline,
    projectPrice,
    penaltyPercentage,
    status,
    isHidden,
  ];
}
