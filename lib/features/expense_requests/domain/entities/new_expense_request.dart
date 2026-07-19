import '../../../reports/domain/entities/expense_report.dart';

/// Yangi xarajat so'rovi (`POST /expense-request/`) kiritma qiymatlari.
///
/// Turi bo'yicha maydon qulflari (data source shu asosda body quradi):
/// `company` — faqat [projectId]; `other` — faqat [categoryId]; `withdrawal` —
/// ikkalasi ham yo'q. [paymentMethod] `card` bo'lsagina [cardNumber] yuboriladi.
class NewExpenseRequest {
  const NewExpenseRequest({
    required this.type,
    required this.amount,
    required this.paymentMethod,
    this.projectId,
    this.categoryId,
    this.reason,
    this.cardNumber,
  });

  final ExpenseType type;

  /// Decimal string (masalan `"150000"`) — backend patterni
  /// `^-?\d{0,10}(?:\.\d{0,2})?$`; UI manfiy qiymatga yo'l qo'ymaydi.
  final String amount;
  final ExpensePaymentMethod paymentMethod;
  final int? projectId;
  final int? categoryId;
  final String? reason;
  final String? cardNumber;
}
