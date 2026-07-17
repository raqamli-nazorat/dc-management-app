import 'package:equatable/equatable.dart';

/// Tranzaksiya turi (`transaction_type`): `debit` — Chiqim, `credit` — Kirim.
enum TransactionType {
  debit('debit'),
  credit('credit'),
  unknown('');

  const TransactionType(this.apiValue);

  final String apiValue;

  static TransactionType fromApi(String? raw) {
    switch (raw) {
      case 'debit':
        return TransactionType.debit;
      case 'credit':
        return TransactionType.credit;
      default:
        return TransactionType.unknown;
    }
  }
}

/// Arxiv/moliya tarixi yozuvi (`GET /ledger/` va `GET /ledger/{id}/` — `Ledger`
/// sxemasi). Ro'yxat kartasi va detail bir xil sxemadan oziqlanadi.
class LedgerEntry extends Equatable {
  const LedgerEntry({
    required this.id,
    required this.userName,
    required this.avatar,
    required this.fixedSalary,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.createdAt,
  });

  final int id;

  /// `user_info.username`.
  final String userName;

  /// `user_info.avatar`.
  final String avatar;

  /// `user_info.fixed_salary` (Profile "Oylik maosh") — API decimal string.
  final String fixedSalary;

  /// `amount` — API decimal string, masalan `75000.00`.
  final String amount;

  final TransactionType transactionType;

  final String description;

  final DateTime? createdAt;

  @override
  List<Object?> get props => [
    id,
    userName,
    avatar,
    fixedSalary,
    amount,
    transactionType,
    description,
    createdAt,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef LedgerPage = ({List<LedgerEntry> items, bool hasMore});
