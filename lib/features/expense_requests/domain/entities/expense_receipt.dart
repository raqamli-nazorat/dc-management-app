import 'package:equatable/equatable.dart';

/// Xarajat cheki (`ExpenseReceipt` sxemasi) — bitta so'rovga biriktirilgan
/// to'lov cheki/kvitansiyasi fayli.
class ExpenseReceipt extends Equatable {
  const ExpenseReceipt({
    required this.id,
    required this.expenseId,
    required this.fileUrl,
  });

  final int id;

  /// `expense` — biriktirilgan xarajat so'rovi id'si.
  final int expenseId;

  /// `file` — chek rasm/hujjat URL'i.
  final String fileUrl;

  @override
  List<Object?> get props => [id, expenseId, fileUrl];
}
