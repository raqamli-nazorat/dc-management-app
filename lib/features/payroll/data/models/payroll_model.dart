import '../../domain/entities/payroll.dart';

/// `Payroll` sxemasi → [Payroll] entity. Bardoshli parsing: `user_info` obyekt
/// yoki yo'q; decimal maydonlar string yoki son.
abstract final class PayrollModel {
  static Payroll fromJson(Map<String, dynamic> json) {
    final user = json['user_info'];
    final userMap = user is Map ? user.cast<String, dynamic>() : const {};
    return Payroll(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: userMap['username'] as String? ?? '',
      avatar: userMap['avatar'] as String? ?? '',
      monthDisplay: json['month_display'] as String? ?? '',
      fixedSalary: _decimal(json['fixed_salary']),
      kpiBonus: _decimal(json['kpi_bonus']),
      penaltyAmount: _decimal(json['penalty_amount']),
      totalAmount: _decimal(json['total_amount']),
      isConfirmed: json['is_confirmed'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  static String _decimal(Object? value) => value == null ? '' : '$value';
}
