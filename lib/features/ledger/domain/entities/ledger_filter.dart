import 'package:equatable/equatable.dart';

import 'ledger_entry.dart';

/// Moliya tarixi filtri (`GET /ledger/` query paramlari).
///
/// Maydon → param moslashuvi:
/// - [transactionType] → `transaction_type` (Xarajat turi: Chiqim/Kirim)
/// - [dateFrom]/[dateTo] → `created_at__gte`/`created_at__lte` (Sana oralig'i)
/// - [amountFrom]/[amountTo] → `amount__gte`/`amount__lte` (Miqdor)
/// - [search] → `search`
class LedgerFilter extends Equatable {
  const LedgerFilter({
    this.transactionType,
    this.dateFrom,
    this.dateTo,
    this.amountFrom,
    this.amountTo,
    this.search = '',
  });

  static const empty = LedgerFilter();

  final TransactionType? transactionType;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final num? amountFrom;
  final num? amountTo;
  final String search;

  bool get hasActiveFilters =>
      transactionType != null ||
      dateFrom != null ||
      dateTo != null ||
      amountFrom != null ||
      amountTo != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  LedgerFilter copyWithSearch(String search) => LedgerFilter(
    transactionType: transactionType,
    dateFrom: dateFrom,
    dateTo: dateTo,
    amountFrom: amountFrom,
    amountTo: amountTo,
    search: search,
  );

  @override
  List<Object?> get props => [
    transactionType,
    dateFrom,
    dateTo,
    amountFrom,
    amountTo,
    search,
  ];
}
