import '../../../../core/usecases/usecase.dart';
import '../entities/expense_request.dart';
import '../entities/expense_request_filter.dart';
import '../repository/expense_requests_repository.dart';

/// [GetExpenseRequestsUseCase] parametri: sahifa raqami + filtr.
typedef GetExpenseRequestsParams = ({int page, ExpenseRequestFilter filter});

/// Xarajat so'rovlari sahifasini olish (`GET /expense-request/`).
class GetExpenseRequestsUseCase
    implements UseCase<ExpenseRequestPage, GetExpenseRequestsParams> {
  const GetExpenseRequestsUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<ExpenseRequestPage> call(GetExpenseRequestsParams params) =>
      _repository.getExpenseRequests(page: params.page, filter: params.filter);
}
