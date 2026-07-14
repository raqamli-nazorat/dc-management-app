import 'package:equatable/equatable.dart';

/// Bitta sahifa natijasi: yuklangan xodim hisobotlari + yana sahifa
/// bor-yo'qligi (`next != null`).
typedef UserReportPage = ({List<UserReport> items, bool hasMore});

/// `report` maydonidagi sonli ko'rsatkichlar (loyiha/vazifa/yig'ilish/xarajat/
/// ish haqi). Backend schema bu maydonni tipsiz `string` deb belgilagan —
/// haqiqiy shakli tasdiqlanmagan. [UserReportModel] uni JSON deb o'qishga
/// urinadi; muvaffaqiyatsiz bo'lsa hammasi 0 bo'lib qoladi (bloklamaydi).
class UserReportBreakdown extends Equatable {
  const UserReportBreakdown({
    this.projectsTotal = 0,
    this.projectsCompleted = 0,
    this.tasksTotal = 0,
    this.tasksTodo = 0,
    this.meetingsTotal = 0,
    this.meetingsAttended = 0,
    this.expensesPaid = 0,
    this.payrollKpiBonus = 0,
  });

  static const empty = UserReportBreakdown();

  final int projectsTotal;
  final int projectsCompleted;
  final int tasksTotal;
  final int tasksTodo;
  final int meetingsTotal;
  final int meetingsAttended;
  final num expensesPaid;
  final num payrollKpiBonus;

  @override
  List<Object?> get props => [
    projectsTotal,
    projectsCompleted,
    tasksTotal,
    tasksTodo,
    meetingsTotal,
    meetingsAttended,
    expensesPaid,
    payrollKpiBonus,
  ];
}

/// Bitta xodim bo'yicha hisobot qatori (`GET /reports/users/`).
class UserReport extends Equatable {
  const UserReport({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.region,
    required this.district,
    required this.position,
    required this.fixedSalary,
    required this.balance,
    required this.dateJoined,
    required this.breakdown,
  });

  final int id;
  final String fullName;
  final String phoneNumber;
  final String region;
  final String district;
  final String position;
  final num fixedSalary;
  final num balance;
  final DateTime? dateJoined;
  final UserReportBreakdown breakdown;

  @override
  List<Object?> get props => [
    id,
    fullName,
    phoneNumber,
    region,
    district,
    position,
    fixedSalary,
    balance,
    dateJoined,
    breakdown,
  ];
}
