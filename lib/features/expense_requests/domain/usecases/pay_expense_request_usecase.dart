import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../repository/expense_requests_repository.dart';

/// To'lovni qayd etish (`POST /expense-request/{id}/pay/`).
class PayExpenseRequestUseCase implements UseCase<ExpenseRequest, int> {
  const PayExpenseRequestUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequest> call(int id) => _repository.payExpenseRequest(id);
}
