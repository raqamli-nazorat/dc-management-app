import 'package:equatable/equatable.dart';

import '../../../reports/domain/entities/expense_report.dart';

/// Xarajat so'rovi yozuvi (`GET /expense-request/` va
/// `GET /expense-request/{id}/` — `ExpenseRequest` sxemasi). Ro'yxat kartasi
/// va detail bir xil sxemadan oziqlanadi.
class ExpenseRequest extends Equatable {
  const ExpenseRequest({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.projectName,
    required this.categoryName,
    required this.type,
    required this.amount,
    required this.reason,
    required this.cancelReason,
    required this.paymentMethod,
    required this.cardNumber,
    required this.status,
    required this.createdAt,
    required this.paidAt,
    required this.confirmedAt,
  });

  final int id;

  /// `user_info.username`.
  final String userName;

  /// `user_info.avatar`.
  final String avatar;

  /// `project_info.title` (loyiha biriktirilmagan bo'lishi mumkin — bo'sh).
  final String projectName;

  /// `expense_category_info.title` (faqat "Boshqa" turida bo'ladi).
  final String categoryName;

  /// `type` — withdrawal/company/other (hisobotlardagi enum qayta ishlatiladi).
  final ExpenseType type;

  /// API decimal string (`amount`).
  final String amount;

  /// `reason` — so'rov sababi.
  final String reason;

  /// `cancel_reason` — rad etish sababi (faqat `cancelled` holatda).
  final String cancelReason;

  /// `payment_method` — to'lov turi (naqd/karta).
  final ExpensePaymentMethod paymentMethod;

  /// `card_number` — karta raqami (karta orqali to'lovda).
  final String cardNumber;

  /// `status` — karta checkbox `confirmed` holatini ko'rsatadi; detail
  /// tugmalari faqat `pending`da chiqadi.
  final ExpenseStatus status;

  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? confirmedAt;

  @override
  List<Object?> get props => [
    id,
    userName,
    avatar,
    projectName,
    categoryName,
    type,
    amount,
    reason,
    cancelReason,
    paymentMethod,
    cardNumber,
    status,
    createdAt,
    paidAt,
    confirmedAt,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef ExpenseRequestPage = ({List<ExpenseRequest> items, bool hasMore});
