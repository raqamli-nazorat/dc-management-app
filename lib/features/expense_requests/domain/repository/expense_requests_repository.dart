import '../entities/expense_request.dart';
import '../entities/expense_request_filter.dart';

/// Xarajat so'rovlari domen shartnomasi. Implementatsiya `Exception`larni
/// `Failure`ga aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class ExpenseRequestsRepository {
  /// Bitta sahifa (`GET /expense-request/?page=` + filtr paramlari).
  Future<ExpenseRequestPage> getExpenseRequests({
    int page,
    ExpenseRequestFilter filter,
  });

  /// Bitta so'rov (`GET /expense-request/{id}/`).
  Future<ExpenseRequest> getExpenseRequest(int id);

  /// To'lovni qayd etish (`POST /expense-request/{id}/pay/`) — yangilangan
  /// so'rov qaytadi.
  Future<ExpenseRequest> payExpenseRequest(int id);

  /// Rad etish (`POST /expense-request/{id}/cancel/` — `{cancel_reason}`).
  Future<ExpenseRequest> cancelExpenseRequest(int id, String reason);
}
