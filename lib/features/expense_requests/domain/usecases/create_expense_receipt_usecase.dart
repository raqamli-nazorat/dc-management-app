import '../../../../core/usecases/usecase.dart';
import '../repository/expense_requests_repository.dart';

/// [CreateExpenseReceiptUseCase] parametri: so'rov id + fayl yo'li.
typedef CreateExpenseReceiptParams = ({int expenseId, String filePath});

/// Chek yuklash (multipart `POST /expense-receipt/`).
class CreateExpenseReceiptUseCase
    implements UseCase<void, CreateExpenseReceiptParams> {
  const CreateExpenseReceiptUseCase(this._repository);

  final ExpenseRequestsRepository _repository;

  @override
  Future<void> call(CreateExpenseReceiptParams params) =>
      _repository.createReceipt(params.expenseId, params.filePath);
}
