import '../../../../core/usecases/usecase.dart';
import '../entities/task_report.dart';
import '../entities/task_report_filter.dart';
import '../repository/reports_repository.dart';

typedef GetTaskReportsParams = ({int page, TaskReportFilter filter});

class GetTaskReportsUseCase
    implements UseCase<TaskReportPage, GetTaskReportsParams> {
  const GetTaskReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<TaskReportPage> call(GetTaskReportsParams params) =>
      _repository.getTaskReports(page: params.page, filter: params.filter);
}
