import 'package:equatable/equatable.dart';

/// Ish haqi yozuvi (`GET /payroll/` va `GET /payroll/{id}/` — `Payroll`
/// sxemasi). Ro'yxat kartasi va detail bir xil sxemadan oziqlanadi.
class Payroll extends Equatable {
  const Payroll({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.monthDisplay,
    required this.fixedSalary,
    required this.kpiBonus,
    required this.penaltyAmount,
    required this.totalAmount,
    required this.isConfirmed,
    required this.createdAt,
  });

  final int id;

  /// `user_info.username`.
  final String userName;

  /// `user_info.avatar`.
  final String avatar;

  /// `month_display` — masalan "Yanvar".
  final String monthDisplay;

  /// API decimal string (`fixed_salary`) — Oylik maosh.
  final String fixedSalary;

  /// API decimal string (`kpi_bonus`).
  final String kpiBonus;

  /// API decimal string (`penalty_amount`) — UIda manfiy/qizil ko'rsatiladi.
  final String penaltyAmount;

  /// API decimal string (`total_amount`) — Jami miqdori.
  final String totalAmount;

  /// `is_confirmed` — karta checkbox va detail tugmasi holati.
  final bool isConfirmed;

  final DateTime? createdAt;

  /// Tasdiqlashdan keyin `is_confirmed`ni `true` qilib nusxa (optimistik UI —
  /// endpoint yangi obyekt qaytarmaydi).
  Payroll copyWithConfirmed() => Payroll(
    id: id,
    userName: userName,
    avatar: avatar,
    monthDisplay: monthDisplay,
    fixedSalary: fixedSalary,
    kpiBonus: kpiBonus,
    penaltyAmount: penaltyAmount,
    totalAmount: totalAmount,
    isConfirmed: true,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    userName,
    avatar,
    monthDisplay,
    fixedSalary,
    kpiBonus,
    penaltyAmount,
    totalAmount,
    isConfirmed,
    createdAt,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef PayrollPage = ({List<Payroll> items, bool hasMore});
