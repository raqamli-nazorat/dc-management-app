import '../../../../core/usecases/usecase.dart';
import '../entities/expense_report_filter.dart';
import '../repository/reports_repository.dart';

class GetExpenseReportOptionsUseCase
    implements UseCase<ExpenseReportOptions, void> {
  const GetExpenseReportOptionsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<ExpenseReportOptions> call([void _]) =>
      _repository.getExpenseReportOptions();
}
