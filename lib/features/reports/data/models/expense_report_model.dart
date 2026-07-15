import '../../domain/entities/expense_report.dart';

class ExpenseReportModel extends ExpenseReport {
  const ExpenseReportModel({
    required super.id,
    required super.user,
    required super.accountant,
    required super.project,
    required super.type,
    required super.expenseCategory,
    required super.amount,
    required super.reason,
    required super.cancelReason,
    required super.paymentMethod,
    required super.cardNumber,
    required super.status,
    required super.createdAt,
    required super.paidAt,
    required super.confirmedAt,
    required super.cancelledAt,
  });

  factory ExpenseReportModel.fromJson(Map<String, dynamic> json) =>
      ExpenseReportModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        user: json['user']?.toString() ?? '',
        accountant: json['accountant']?.toString() ?? '',
        project: json['project']?.toString() ?? '',
        type: ExpenseType.fromApi(json['type'] as String?),
        expenseCategory: json['expense_category']?.toString() ?? '',
        amount: _number(json['amount']),
        reason: json['reason']?.toString() ?? '',
        cancelReason: json['cancel_reason']?.toString() ?? '',
        paymentMethod: ExpensePaymentMethod.fromApi(
          json['payment_method'] as String?,
        ),
        cardNumber: json['card_number']?.toString() ?? '',
        status: ExpenseStatus.fromApi(json['status'] as String?),
        createdAt: _date(json['created_at']),
        paidAt: _date(json['paid_at']),
        confirmedAt: _date(json['confirmed_at']),
        cancelledAt: _date(json['cancelled_at']),
      );

  static num _number(Object? value) =>
      value is num ? value : num.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _date(Object? value) =>
      DateTime.tryParse(value?.toString() ?? '');
}
