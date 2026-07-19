import '../../domain/entities/expense_receipt.dart';

/// `ExpenseReceipt` sxemasi → [ExpenseReceipt] entity.
abstract final class ExpenseReceiptModel {
  static ExpenseReceipt fromJson(Map<String, dynamic> json) => ExpenseReceipt(
    id: (json['id'] as num?)?.toInt() ?? 0,
    expenseId: (json['expense'] as num?)?.toInt() ?? 0,
    fileUrl: json['file'] as String? ?? '',
  );
}
