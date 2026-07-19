import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../entities/new_expense_request.dart';
import '../repository/expense_requests_repository.dart';

/// Yangi xarajat so'rovi yaratish (`POST /expense-request/`).
class CreateExpenseRequestUseCase
    implements UseCase<ExpenseRequest, NewExpenseRequest> {
  const CreateExpenseRequestUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequest> call(NewExpenseRequest request) =>
      _repository.createExpenseRequest(request);
}
