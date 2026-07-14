import '../../../../core/util/lenient_json.dart';
import '../../domain/entities/user_report.dart';

/// [UserReport] uchun JSON mapping (`GET /reports/users/`).
class UserReportModel extends UserReport {
  const UserReportModel({
    required super.id,
    required super.fullName,
    required super.phoneNumber,
    required super.region,
    required super.district,
    required super.position,
    required super.fixedSalary,
    required super.balance,
    required super.dateJoined,
    required super.breakdown,
  });

  factory UserReportModel.fromJson(Map<String, dynamic> json) =>
      UserReportModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        fullName: json['username'] as String? ?? '',
        phoneNumber: json['phone_number'] as String? ?? '',
        region: json['region'] as String? ?? '',
        district: json['district'] as String? ?? '',
        position: json['position'] as String? ?? '',
        fixedSalary: _asNum(json['fixed_salary']),
        balance: _asNum(json['balance']),
        dateJoined: DateTime.tryParse(json['date_joined'] as String? ?? ''),
        breakdown: _parseBreakdown(json['report']),
      );

  static num _asNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  /// `report` — schema bo'yicha tipsiz `string`; haqiqiy shakli tasdiqlanmagan.
  /// Backend uni JSON obyekt sifatida yuborishi mumkin (tipsiz
  /// `SerializerMethodField` ko'pincha shunday schema hosil qiladi) — shu
  /// sabab avval xom qiymatni to'g'ridan-to'g'ri `Map` deb tekshiramiz, keyin
  /// (string bo'lsa) `lenientJsonDecode` bilan qayta uriniladi. Kalit nomlari
  /// taxminiy — real javobga qarab moslashtirish kerak.
  static UserReportBreakdown _parseBreakdown(Object? raw) {
    final Map<String, dynamic>? map = switch (raw) {
      Map<String, dynamic> m => m,
      Map m => m.cast<String, dynamic>(),
      String s => lenientJsonDecode(s),
      _ => null,
    };
    if (map == null) return UserReportBreakdown.empty;

    Map<String, dynamic>? section(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value is Map) return value.cast<String, dynamic>();
      }
      return null;
    }

    int asInt(Map<String, dynamic>? m, List<String> keys) {
      if (m == null) return 0;
      for (final key in keys) {
        final value = m[key];
        if (value is num) return value.toInt();
      }
      return 0;
    }

    num asAmount(Map<String, dynamic>? m, List<String> keys) {
      if (m == null) return 0;
      for (final key in keys) {
        final value = m[key];
        if (value is num) return value;
        if (value is String) {
          final parsed = num.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
      return 0;
    }

    final projects = section(['projects', 'loyihalar']);
    final tasks = section(['tasks', 'vazifalar']);
    final meetings = section(['meetings', 'yigilishlar']);
    final expenses = section(['expenses', 'expense', 'xarajat_sorovlari']);
    final payroll = section(['payroll', 'ish_haqi']);

    return UserReportBreakdown(
      projectsTotal: asInt(projects, ['total', 'count']),
      projectsCompleted: asInt(projects, ['completed', 'done']),
      tasksTotal: asInt(tasks, ['total', 'count']),
      tasksTodo: asInt(tasks, ['todo']),
      meetingsTotal: asInt(meetings, ['total', 'count']),
      meetingsAttended: asInt(meetings, ['attended', 'completed', 'done']),
      expensesPaid: asAmount(expenses, ['paid', 'confirmed', 'paid_amount']),
      payrollKpiBonus: asAmount(payroll, ['kpi', 'kpi_bonus']),
    );
  }
}
