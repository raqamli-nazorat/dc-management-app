import 'package:equatable/equatable.dart';

import '../../../projects/domain/entities/project.dart';
import '../../../tasks/domain/entities/task.dart';

/// Viloyat (`GET /applications/regions/`).
class Region extends Equatable {
  const Region({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Tuman (`GET /applications/districts/?region=`).
class District extends Equatable {
  const District({
    required this.id,
    required this.name,
    required this.regionId,
  });

  final int id;
  final String name;
  final int regionId;

  @override
  List<Object?> get props => [id, name, regionId];
}

/// Yig'ilish ishtirok holati (`meetings_status`).
enum ReportMeetingStatus {
  attended,
  absentReason,
  absentNoReason;

  static ReportMeetingStatus? fromApi(String? value) => switch (value) {
    'attended' => ReportMeetingStatus.attended,
    'absent_reason' => ReportMeetingStatus.absentReason,
    'absent_no_reason' => ReportMeetingStatus.absentNoReason,
    _ => null,
  };

  String get apiValue => switch (this) {
    ReportMeetingStatus.attended => 'attended',
    ReportMeetingStatus.absentReason => 'absent_reason',
    ReportMeetingStatus.absentNoReason => 'absent_no_reason',
  };
}

/// Xarajat so'rovi holati (`expense_status`).
enum ReportExpenseStatus {
  all,
  pending,
  confirmed,
  paidUnconfirmed,
  cancelled;

  String get apiValue => switch (this) {
    ReportExpenseStatus.all => 'all',
    ReportExpenseStatus.pending => 'pending',
    ReportExpenseStatus.confirmed => 'confirmed',
    ReportExpenseStatus.paidUnconfirmed => 'paid_unconfirmed',
    ReportExpenseStatus.cancelled => 'cancelled',
  };
}

/// Ish haqi turi (`payroll_type`) — dan/gacha oralig'i qaysi summaga
/// tegishli ekanini tanlaydi.
enum ReportPayrollType {
  total,
  kpi,
  penalty;

  String get apiValue => switch (this) {
    ReportPayrollType.total => 'total',
    ReportPayrollType.kpi => 'kpi',
    ReportPayrollType.penalty => 'penalty',
  };
}

/// Xodim bo'yicha hisobot filtri (`GET /reports/users/` query paramlari).
///
/// Maydon → param moslashuvi:
/// - [joinedFrom]/[joinedTo] → `joined_min`/`joined_max` (Muddati)
/// - [positionId] → `position` (Lavozimi — bitta tanlov, vergul bilan yuboriladi)
/// - [regionId] → `region` (Viloyat)
/// - [employeeIds] → `users` (Xodimlar — ko'p tanlov)
/// - [salaryFrom]/[salaryTo] → `salary_min`/`salary_max`
/// - [balanceFrom]/[balanceTo] → `balance_min`/`balance_max`
/// - [projectStatus] → `project_status`; [projectsFrom]/[projectsTo] → `projects_min`/`projects_max`
/// - [taskStatus] → `task_status`; [tasksFrom]/[tasksTo] → `tasks_min`/`tasks_max`
/// - [meetingStatus] → `meetings_status`; [meetingsFrom]/[meetingsTo] → `meetings_min`/`meetings_max`
/// - [expenseStatus] → `expense_status`; [expensesFrom]/[expensesTo] → `expenses_amount_min`/`expenses_amount_max`
/// - [payrollType] → `payroll_type`; [payrollsFrom]/[payrollsTo] → `payrolls_amount_min`/`payrolls_amount_max`
/// - [search] → `search`
class UserReportFilter extends Equatable {
  const UserReportFilter({
    this.joinedFrom,
    this.joinedTo,
    this.positionId,
    this.regionId,
    this.employeeIds = const {},
    this.salaryFrom,
    this.salaryTo,
    this.balanceFrom,
    this.balanceTo,
    this.projectStatus,
    this.projectsFrom,
    this.projectsTo,
    this.taskStatus,
    this.tasksFrom,
    this.tasksTo,
    this.meetingStatus,
    this.meetingsFrom,
    this.meetingsTo,
    this.expenseStatus,
    this.expensesFrom,
    this.expensesTo,
    this.payrollType,
    this.payrollsFrom,
    this.payrollsTo,
    this.search = '',
  });

  static const empty = UserReportFilter();

  final DateTime? joinedFrom;
  final DateTime? joinedTo;
  final int? positionId;
  final int? regionId;
  final Set<int> employeeIds;
  final num? salaryFrom;
  final num? salaryTo;
  final num? balanceFrom;
  final num? balanceTo;
  final ProjectStatus? projectStatus;
  final int? projectsFrom;
  final int? projectsTo;
  final TaskStatus? taskStatus;
  final int? tasksFrom;
  final int? tasksTo;
  final ReportMeetingStatus? meetingStatus;
  final int? meetingsFrom;
  final int? meetingsTo;
  final ReportExpenseStatus? expenseStatus;
  final num? expensesFrom;
  final num? expensesTo;
  final ReportPayrollType? payrollType;
  final num? payrollsFrom;
  final num? payrollsTo;
  final String search;

  bool get hasActiveFilters =>
      joinedFrom != null ||
      joinedTo != null ||
      positionId != null ||
      regionId != null ||
      employeeIds.isNotEmpty ||
      salaryFrom != null ||
      salaryTo != null ||
      balanceFrom != null ||
      balanceTo != null ||
      projectStatus != null ||
      projectsFrom != null ||
      projectsTo != null ||
      taskStatus != null ||
      tasksFrom != null ||
      tasksTo != null ||
      meetingStatus != null ||
      meetingsFrom != null ||
      meetingsTo != null ||
      expenseStatus != null ||
      expensesFrom != null ||
      expensesTo != null ||
      payrollType != null ||
      payrollsFrom != null ||
      payrollsTo != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  UserReportFilter copyWithSearch(String search) => UserReportFilter(
    joinedFrom: joinedFrom,
    joinedTo: joinedTo,
    positionId: positionId,
    regionId: regionId,
    employeeIds: employeeIds,
    salaryFrom: salaryFrom,
    salaryTo: salaryTo,
    balanceFrom: balanceFrom,
    balanceTo: balanceTo,
    projectStatus: projectStatus,
    projectsFrom: projectsFrom,
    projectsTo: projectsTo,
    taskStatus: taskStatus,
    tasksFrom: tasksFrom,
    tasksTo: tasksTo,
    meetingStatus: meetingStatus,
    meetingsFrom: meetingsFrom,
    meetingsTo: meetingsTo,
    expenseStatus: expenseStatus,
    expensesFrom: expensesFrom,
    expensesTo: expensesTo,
    payrollType: payrollType,
    payrollsFrom: payrollsFrom,
    payrollsTo: payrollsTo,
    search: search,
  );

  @override
  List<Object?> get props => [
    joinedFrom,
    joinedTo,
    positionId,
    regionId,
    employeeIds,
    salaryFrom,
    salaryTo,
    balanceFrom,
    balanceTo,
    projectStatus,
    projectsFrom,
    projectsTo,
    taskStatus,
    tasksFrom,
    tasksTo,
    meetingStatus,
    meetingsFrom,
    meetingsTo,
    expenseStatus,
    expensesFrom,
    expensesTo,
    payrollType,
    payrollsFrom,
    payrollsTo,
    search,
  ];
}
