import '../../../../core/usecases/usecase.dart';
import '../entities/project_report.dart';
import '../entities/project_report_filter.dart';
import '../repository/reports_repository.dart';

/// [GetProjectReportsUseCase] parametri: sahifa raqami + filtr.
typedef GetProjectReportsParams = ({int page, ProjectReportFilter filter});

/// Loyihalar bo'yicha hisobot sahifasini olish (`GET /reports/projects/`).
class GetProjectReportsUseCase
    implements UseCase<ProjectReportPage, GetProjectReportsParams> {
  const GetProjectReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<ProjectReportPage> call(GetProjectReportsParams params) =>
      _repository.getProjectReports(page: params.page, filter: params.filter);
}
