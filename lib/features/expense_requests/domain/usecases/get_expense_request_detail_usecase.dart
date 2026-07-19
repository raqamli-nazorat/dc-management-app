import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../repository/expense_requests_repository.dart';

/// Bitta xarajat so'rovini olish (`GET /expense-request/{id}/`).
class GetExpenseRequestDetailUseCase implements UseCase<ExpenseRequest, int> {
  const GetExpenseRequestDetailUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequest> call(int id) => _repository.getExpenseRequest(id);
}
