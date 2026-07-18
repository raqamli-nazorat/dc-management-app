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
}
