import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/project.dart';

/// Bitta sahifa natijasi: yuklangan loyiha hisobotlari + yana sahifa
/// bor-yo'qligi (`next != null`).
typedef ProjectReportPage = ({List<ProjectReport> items, bool hasMore});

/// `task_stats` maydonidagi vazifa holati bo'yicha sonlar. Backend schema bu
/// maydonni tipsiz `string` deb belgilagan — haqiqiy shakli tasdiqlanmagan.
/// [ProjectReportModel] uni JSON deb o'qishga urinadi; muvaffaqiyatsiz bo'lsa
/// hammasi 0 bo'lib qoladi (bloklamaydi).
class ProjectTaskStats extends Equatable {
  const ProjectTaskStats({
    this.todo = 0,
    this.inProgress = 0,
    this.done = 0,
    this.production = 0,
    this.checked = 0,
    this.rejected = 0,
    this.overdue = 0,
  });

  static const empty = ProjectTaskStats();

  final int todo;
  final int inProgress;
  final int done;
  final int production;
  final int checked;
  final int rejected;
  final int overdue;

  int get total =>
      todo + inProgress + done + production + checked + rejected + overdue;

  @override
  List<Object?> get props => [
    todo,
    inProgress,
    done,
    production,
    checked,
    rejected,
    overdue,
  ];
}

/// Bitta loyiha bo'yicha hisobot qatori (`GET /reports/projects/`).
class ProjectReport extends Equatable {
  const ProjectReport({
    required this.id,
    required this.prefix,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
    required this.projectPrice,
    required this.createdByName,
    required this.managerName,
    required this.employeesNames,
    required this.testersNames,
    required this.taskStats,
  });

  final int id;
  final String prefix;
  final String title;
  final String description;
  final DateTime? deadline;
  final ProjectStatus status;
  final num projectPrice;
  final String createdByName;
  final String managerName;
  final String employeesNames;
  final String testersNames;
  final ProjectTaskStats taskStats;

  @override
  List<Object?> get props => [
    id,
    prefix,
    title,
    description,
    deadline,
    status,
    projectPrice,
    createdByName,
    managerName,
    employeesNames,
    testersNames,
    taskStats,
  ];
}
