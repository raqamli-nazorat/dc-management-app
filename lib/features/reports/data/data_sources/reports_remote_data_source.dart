import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/user_report_filter.dart';
import '../models/region_model.dart';
import '../models/user_report_model.dart';

/// Xodimlar bo'yicha hisobot backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class ReportsRemoteDataSource {
  /// Bitta sahifa (`GET /reports/users/?page=` + filtr paramlari).
  Future<UserReportPage> getUserReports({int page, UserReportFilter filter});

  /// Viloyatlar ro'yxati — filtr "Viloyat" tanlovi (`GET /applications/regions/`).
  Future<List<Region>> getRegions();
}

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  const ReportsRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<UserReportPage> getUserReports({
    int page = 1,
    UserReportFilter filter = UserReportFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.reportsUsers,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => UserReportModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [UserReportFilter] → `GET /reports/users/` query paramlari (faqat
  /// to'ldirilganlari).
  Map<String, dynamic> _filterParams(UserReportFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.joinedFrom != null) 'joined_min': f.joinedFrom!.toIso8601String(),
    if (f.joinedTo != null) 'joined_max': f.joinedTo!.toIso8601String(),
    if (f.positionId != null) 'position': '${f.positionId}',
    if (f.regionId != null) 'region': '${f.regionId}',
    if (f.employeeIds.isNotEmpty) 'users': f.employeeIds.join(','),
    if (f.salaryFrom != null) 'salary_min': f.salaryFrom,
    if (f.salaryTo != null) 'salary_max': f.salaryTo,
    if (f.balanceFrom != null) 'balance_min': f.balanceFrom,
    if (f.balanceTo != null) 'balance_max': f.balanceTo,
    if (f.projectStatus?.apiValue != null)
      'project_status': f.projectStatus!.apiValue,
    if (f.projectsFrom != null) 'projects_min': f.projectsFrom,
    if (f.projectsTo != null) 'projects_max': f.projectsTo,
    if (f.taskStatus?.apiValue != null) 'task_status': f.taskStatus!.apiValue,
    if (f.tasksFrom != null) 'tasks_min': f.tasksFrom,
    if (f.tasksTo != null) 'tasks_max': f.tasksTo,
    if (f.meetingStatus != null) 'meetings_status': f.meetingStatus!.apiValue,
    if (f.meetingsFrom != null) 'meetings_min': f.meetingsFrom,
    if (f.meetingsTo != null) 'meetings_max': f.meetingsTo,
    if (f.expenseStatus != null) 'expense_status': f.expenseStatus!.apiValue,
    if (f.expensesFrom != null) 'expenses_amount_min': f.expensesFrom,
    if (f.expensesTo != null) 'expenses_amount_max': f.expensesTo,
    if (f.payrollType != null) 'payroll_type': f.payrollType!.apiValue,
    if (f.payrollsFrom != null) 'payrolls_amount_min': f.payrollsFrom,
    if (f.payrollsTo != null) 'payrolls_amount_max': f.payrollsTo,
  };

  @override
  Future<List<Region>> getRegions() async {
    try {
      final response = await _client.get(
        ApiConstants.applicationsRegions,
        queryParameters: {'page_size': 100},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => RegionModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
