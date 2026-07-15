import '../../../../core/usecases/usecase.dart';
import '../entities/payroll_report.dart';
import '../entities/payroll_report_filter.dart';
import '../repository/reports_repository.dart';

typedef GetPayrollReportsParams = ({int page, PayrollReportFilter filter});

class GetPayrollReportsUseCase
    implements UseCase<PayrollReportPage, GetPayrollReportsParams> {
  const GetPayrollReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<PayrollReportPage> call(GetPayrollReportsParams params) =>
      _repository.getPayrollReports(page: params.page, filter: params.filter);
}
