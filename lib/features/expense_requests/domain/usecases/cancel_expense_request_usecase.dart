import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../repository/expense_requests_repository.dart';

/// [CancelExpenseRequestUseCase] parametri: so'rov id + rad etish sababi.
typedef CancelExpenseRequestParams = ({int id, String reason});

/// Rad etish (`POST /expense-request/{id}/cancel/` — `{cancel_reason}`).
class CancelExpenseRequestUseCase
    implements UseCase<ExpenseRequest, CancelExpenseRequestParams> {
  const CancelExpenseRequestUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequest> call(CancelExpenseRequestParams params) =>
      _repository.cancelExpenseRequest(params.id, params.reason);
}
