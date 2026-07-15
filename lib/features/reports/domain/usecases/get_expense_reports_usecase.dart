import '../../../../core/usecases/usecase.dart';
import '../entities/expense_report.dart';
import '../entities/expense_report_filter.dart';
import '../repository/reports_repository.dart';

typedef GetExpenseReportsParams = ({int page, ExpenseReportFilter filter});

class GetExpenseReportsUseCase
    implements UseCase<ExpenseReportPage, GetExpenseReportsParams> {
  const GetExpenseReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<ExpenseReportPage> call(GetExpenseReportsParams params) =>
      _repository.getExpenseReports(page: params.page, filter: params.filter);
}
