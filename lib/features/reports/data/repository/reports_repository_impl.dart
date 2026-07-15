import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project_report.dart';
import '../../domain/entities/project_report_filter.dart';
import '../../domain/entities/expense_report.dart';
import '../../domain/entities/expense_report_filter.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/user_report_filter.dart';
import '../../domain/repository/reports_repository.dart';
import '../data_sources/reports_remote_data_source.dart';

/// [ReportsRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class ReportsRepositoryImpl implements ReportsRepository {
  const ReportsRepositoryImpl(this._remote);

  final ReportsRemoteDataSource _remote;

  @override
  Future<UserReportPage> getUserReports({
    int page = 1,
    UserReportFilter filter = UserReportFilter.empty,
  }) => _guard(() => _remote.getUserReports(page: page, filter: filter));

  @override
  Future<List<Region>> getRegions() => _guard(_remote.getRegions);

  @override
  Future<ProjectReportPage> getProjectReports({
    int page = 1,
    ProjectReportFilter filter = ProjectReportFilter.empty,
  }) => _guard(() => _remote.getProjectReports(page: page, filter: filter));

  @override
  Future<ExpenseReportPage> getExpenseReports({
    int page = 1,
    ExpenseReportFilter filter = ExpenseReportFilter.empty,
  }) => _guard(() => _remote.getExpenseReports(page: page, filter: filter));

  @override
  Future<ExpenseReportOptions> getExpenseReportOptions() =>
      _guard(_remote.getExpenseReportOptions);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
