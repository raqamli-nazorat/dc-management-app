import '../../domain/entities/ledger_entry.dart';

/// `Ledger` sxemasi → [LedgerEntry]. Bardoshli parsing: `user_info` obyekt yoki
/// yo'q; `amount`/`fixed_salary` string yoki son.
abstract final class LedgerModel {
  static LedgerEntry fromJson(Map<String, dynamic> json) {
    final user = json['user_info'];
    final userMap = user is Map ? user.cast<String, dynamic>() : const {};
    return LedgerEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      userName: userMap['username'] as String? ?? '',
      avatar: userMap['avatar'] as String? ?? '',
      fixedSalary: _decimal(userMap['fixed_salary']),
      amount: _decimal(json['amount']),
      transactionType: TransactionType.fromApi(
        json['transaction_type'] as String?,
      ),
      description: json['description'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  static String _decimal(Object? value) => value == null ? '' : '$value';
}
