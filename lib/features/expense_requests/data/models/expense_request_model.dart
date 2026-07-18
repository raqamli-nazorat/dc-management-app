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
    return ExpenseRequest(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: user['username'] as String? ?? '',
      avatar: user['avatar'] as String? ?? '',
      projectName:
          project['title'] as String? ?? project['name'] as String? ?? '',
      type: ExpenseType.fromApi(json['type'] as String?),
      amount: json['amount'] == null ? '' : '${json['amount']}',
      status: ExpenseStatus.fromApi(json['status'] as String?),
    );
  }
}
