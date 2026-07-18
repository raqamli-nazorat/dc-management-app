import 'package:equatable/equatable.dart';

import '../../../reports/domain/entities/expense_report.dart';

/// Xarajat so'rovi yozuvi (`GET /expense-request/` — `ExpenseRequest`
/// sxemasi). Ro'yxat kartasi shu maydonlardan oziqlanadi.
class ExpenseRequest extends Equatable {
  const ExpenseRequest({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.projectName,
    required this.type,
    required this.amount,
    required this.status,
  });

  final int id;

  /// `user_info.username`.
  final String userName;

  /// `user_info.avatar`.
  final String avatar;

  /// `project_info.title` (loyiha biriktirilmagan bo'lishi mumkin — bo'sh).
  final String projectName;

  /// `type` — withdrawal/company/other (hisobotlardagi enum qayta ishlatiladi).
  final ExpenseType type;

  /// API decimal string (`amount`).
  final String amount;

  /// `status` — karta checkbox `confirmed` holatini ko'rsatadi.
  final ExpenseStatus status;

  @override
  List<Object?> get props => [
    id,
    userName,
    avatar,
    projectName,
    type,
    amount,
    status,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef ExpenseRequestPage = ({List<ExpenseRequest> items, bool hasMore});
