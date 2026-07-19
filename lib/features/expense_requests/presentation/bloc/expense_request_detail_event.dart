part of 'expense_request_detail_bloc.dart';

sealed class ExpenseRequestDetailEvent extends Equatable {
  const ExpenseRequestDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Detailni yuklash / qayta yuklash.
class ExpenseRequestDetailRequested extends ExpenseRequestDetailEvent {
  const ExpenseRequestDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

/// "To'lov qildim" tasdiqlandi — chek fayllari (bo'lsa) yuklanadi, so'ng
/// `POST /expense-request/{id}/pay/`. [receiptPaths] bo'sh — chek qo'shmasdan.
class ExpenseRequestPayRequested extends ExpenseRequestDetailEvent {
  const ExpenseRequestPayRequested(this.receiptPaths);

  final List<String> receiptPaths;

  @override
  List<Object?> get props => [receiptPaths];
}

/// "Rad etish" sababi kiritildi — `POST /expense-request/{id}/cancel/`.
class ExpenseRequestCancelRequested extends ExpenseRequestDetailEvent {
  const ExpenseRequestCancelRequested(this.reason);

  final String reason;

  @override
  List<Object?> get props => [reason];
}

/// Yaratuvchi "Tasdiqlash"ni bosdi — `POST /expense-request/{id}/confirm/`.
class ExpenseRequestConfirmRequested extends ExpenseRequestDetailEvent {
  const ExpenseRequestConfirmRequested();
}
