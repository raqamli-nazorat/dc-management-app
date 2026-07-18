import '../../../reports/domain/entities/expense_report.dart';
import '../../domain/entities/expense_request.dart';

/// `ExpenseRequest` sxemasi → [ExpenseRequest] entity. Bardoshli parsing:
/// `user_info`/`project_info` obyekt yoki yo'q; decimal maydonlar string yoki
/// son.
abstract final class ExpenseRequestModel {
  static ExpenseRequest fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> asMap(Object? value) =>
        value is Map ? value.cast<String, dynamic>() : const {};
    final user = asMap(json['user_info']);
    final project = asMap(json['project_info']);
    final category = asMap(json['expense_category_info']);
    DateTime? date(Object? value) =>
        value is String ? DateTime.tryParse(value) : null;
    return ExpenseRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: user['username'] as String? ?? '',
      avatar: user['avatar'] as String? ?? '',
      projectName:
          project['title'] as String? ?? project['name'] as String? ?? '',
      categoryName:
          category['title'] as String? ?? category['name'] as String? ?? '',
      type: ExpenseType.fromApi(json['type'] as String?),
      amount: json['amount'] == null ? '' : '${json['amount']}',
      reason: json['reason'] as String? ?? '',
      cancelReason: json['cancel_reason'] as String? ?? '',
      paymentMethod: ExpensePaymentMethod.fromApi(
        json['payment_method'] as String?,
      ),
      cardNumber: json['card_number'] as String? ?? '',
      status: ExpenseStatus.fromApi(json['status'] as String?),
      createdAt: date(json['created_at']),
      paidAt: date(json['paid_at']),
      confirmedAt: date(json['confirmed_at']),
    );
  }
}
