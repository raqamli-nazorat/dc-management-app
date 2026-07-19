import '../../../../core/usecases/usecase.dart';
import '../entities/expense_receipt.dart';
import '../repository/expense_requests_repository.dart';

/// So'rovga biriktirilgan cheklarni olish (`GET /expense-receipt/?expense=`).
class GetExpenseReceiptsUseCase implements UseCase<List<ExpenseReceipt>, int> {
  const GetExpenseReceiptsUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<List<ExpenseReceipt>> call(int expenseId) =>
      _repository.getReceipts(expenseId);
}
