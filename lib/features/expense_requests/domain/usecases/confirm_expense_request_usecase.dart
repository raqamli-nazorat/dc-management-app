import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../repository/expense_requests_repository.dart';

/// Yaratuvchi tomonidan tasdiqlash (`POST /expense-request/{id}/confirm/`).
class ConfirmExpenseRequestUseCase implements UseCase<ExpenseRequest, int> {
  const ConfirmExpenseRequestUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequest> call(int id) => _repository.confirmExpenseRequest(id);
}
