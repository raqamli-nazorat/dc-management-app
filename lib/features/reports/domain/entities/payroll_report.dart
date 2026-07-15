import 'package:equatable/equatable.dart';

typedef PayrollReportPage = ({List<PayrollReport> items, bool hasMore});

/// Ish haqi hisoboti qatori (`GET /reports/payrolls/`, `PayrollReport`
/// schema). `status` — backend tayyor matn qaytaradi (readOnly string),
/// enum emas.
class PayrollReport extends Equatable {
  const PayrollReport({
    required this.id,
    required this.user,
    required this.accountant,
    required this.month,
    required this.fixedSalary,
    required this.kpiBonus,
    required this.penaltyAmount,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.confirmedAt,
  });

  final int id;
  final String user;
  final String accountant;
  final DateTime? month;
  final num fixedSalary;
  final num kpiBonus;
  final num penaltyAmount;
  final num totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? confirmedAt;

  @override
  List<Object?> get props => [
    id,
    user,
    accountant,
    month,
    fixedSalary,
    kpiBonus,
    penaltyAmount,
    totalAmount,
    status,
    createdAt,
    confirmedAt,
  ];
}
