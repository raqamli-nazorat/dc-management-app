import '../../domain/entities/payroll_report.dart';

class PayrollReportModel extends PayrollReport {
  const PayrollReportModel({
    required super.id,
    required super.user,
    required super.accountant,
    required super.month,
    required super.fixedSalary,
    required super.kpiBonus,
    required super.penaltyAmount,
    required super.totalAmount,
    required super.status,
    required super.createdAt,
    required super.confirmedAt,
  });

  factory PayrollReportModel.fromJson(Map<String, dynamic> json) =>
      PayrollReportModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        user: json['user']?.toString() ?? '',
        accountant: json['accountant']?.toString() ?? '',
        month: _date(json['month']),
        fixedSalary: _number(json['fixed_salary']),
        kpiBonus: _number(json['kpi_bonus']),
        penaltyAmount: _number(json['penalty_amount']),
        totalAmount: _number(json['total_amount']),
        status: json['status']?.toString() ?? '',
        createdAt: _date(json['created_at']),
        confirmedAt: _date(json['confirmed_at']),
      );

  static num _number(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
