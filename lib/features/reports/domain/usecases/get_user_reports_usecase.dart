import '../../../../core/usecases/usecase.dart';
import '../entities/user_report.dart';
import '../entities/user_report_filter.dart';
import '../repository/reports_repository.dart';

/// [GetUserReportsUseCase] parametri: sahifa raqami + filtr.
typedef GetUserReportsParams = ({int page, UserReportFilter filter});

/// Xodimlar bo'yicha hisobot sahifasini olish (`GET /reports/users/`).
class GetUserReportsUseCase
    implements UseCase<UserReportPage, GetUserReportsParams> {
  const GetUserReportsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<UserReportPage> call(GetUserReportsParams params) =>
      _repository.getUserReports(page: params.page, filter: params.filter);
}
