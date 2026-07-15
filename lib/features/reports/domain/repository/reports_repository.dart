import '../entities/project_report.dart';
import '../entities/project_report_filter.dart';
import '../entities/user_report.dart';
import '../entities/user_report_filter.dart';

/// Hisobotlar domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class ReportsRepository {
  /// Xodimlar bo'yicha hisobot sahifasi (`GET /reports/users/?page=` + filtr).
  Future<UserReportPage> getUserReports({int page, UserReportFilter filter});

  /// Viloyatlar ro'yxati (`GET /applications/regions/`).
  Future<List<Region>> getRegions();

  /// Loyihalar bo'yicha hisobot sahifasi (`GET /reports/projects/?page=` + filtr).
  Future<ProjectReportPage> getProjectReports({
    int page,
    ProjectReportFilter filter,
  });
}
