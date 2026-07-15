import '../../../../core/usecases/usecase.dart';
import '../entities/payroll_report.dart';
import '../repository/reports_repository.dart';

typedef GetPayrollReportsParams = ({int page, String search});

class GetPayrollReportsUseCase
    implements UseCase<PayrollReportPage, GetPayrollReportsParams> {
  const GetPayrollReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<PayrollReportPage> call(GetPayrollReportsParams params) =>
      _repository.getPayrollReports(page: params.page, search: params.search);
}
