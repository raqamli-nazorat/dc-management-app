import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/project_report.dart';
import '../../domain/entities/project_report_filter.dart';
import '../../domain/entities/expense_report.dart';
import '../../domain/entities/expense_report_filter.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/user_report_filter.dart';
import '../../domain/entities/payroll_report.dart';
import '../../domain/entities/task_report.dart';
import '../../domain/entities/task_report_filter.dart';
import '../models/payroll_report_model.dart';
import '../models/project_report_model.dart';
import '../models/expense_report_model.dart';
import '../models/region_model.dart';
import '../models/task_report_model.dart';
import '../models/user_report_model.dart';

/// Xodimlar/loyihalar bo'yicha hisobot backend bilan to'g'ridan-to'g'ri
/// muloqot.
abstract interface class ReportsRemoteDataSource {
  /// Bitta sahifa (`GET /reports/users/?page=` + filtr paramlari).
  Future<UserReportPage> getUserReports({int page, UserReportFilter filter});

  /// Viloyatlar ro'yxati — filtr "Viloyat" tanlovi (`GET /applications/regions/`).
  Future<List<Region>> getRegions();

  /// Loyihalar bo'yicha hisobot sahifasi (`GET /reports/projects/?page=` + filtr).
  Future<ProjectReportPage> getProjectReports({
    int page,
    ProjectReportFilter filter,
  });

  Future<ExpenseReportPage> getExpenseReports({
    int page,
    ExpenseReportFilter filter,
  });

  Future<ExpenseReportOptions> getExpenseReportOptions();

  /// Vazifalar bo'yicha hisobot sahifasi (`GET /reports/tasks/?page=` + filtr).
  Future<TaskReportPage> getTaskReports({int page, TaskReportFilter filter});

  /// Ish haqi bo'yicha hisobot sahifasi (`GET /reports/payrolls/?page=` +
  /// ixtiyoriy `search`).
  Future<PayrollReportPage> getPayrollReports({int page, String search});
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

  @override
  Future<ProjectReportPage> getProjectReports({
    int page = 1,
    ProjectReportFilter filter = ProjectReportFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.reportsProjects,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._projectFilterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => ProjectReportModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [ProjectReportFilter] → `GET /reports/projects/` query paramlari (faqat
  /// to'ldirilganlari).
  Map<String, dynamic> _projectFilterParams(ProjectReportFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.deadlineFrom != null)
      'deadline_min': f.deadlineFrom!.toIso8601String(),
    if (f.deadlineTo != null) 'deadline_max': f.deadlineTo!.toIso8601String(),
    if (f.priceFrom != null) 'price_min': f.priceFrom,
    if (f.priceTo != null) 'price_max': f.priceTo,
    if (f.authorIds.isNotEmpty) 'created_by': f.authorIds.join(','),
    if (f.managerIds.isNotEmpty) 'manager': f.managerIds.join(','),
    if (f.employeeIds.isNotEmpty) 'employees': f.employeeIds.join(','),
    if (f.testerIds.isNotEmpty) 'testers': f.testerIds.join(','),
  };

  @override
  Future<ExpenseReportPage> getExpenseReports({
    int page = 1,
    ExpenseReportFilter filter = ExpenseReportFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.reportsExpenses,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._expenseFilterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => ExpenseReportModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ExpenseReportOptions> getExpenseReportOptions() async {
    try {
      final responses = await Future.wait([
        _client.get(
          ApiConstants.projectShorts,
          queryParameters: {'page_size': 200},
        ),
        // expense_category_list — sahifalanmaydi (oddiy massiv qaytaradi),
        // shuning uchun page_size yubormaymiz.
        _client.get(ApiConstants.expenseCategories),
      ]);
      List<ExpenseFilterOption> options(Response response, List<String> keys) =>
          ResponseMapper.asList(response.data)
              .whereType<Map>()
              .map((item) {
                final map = item.cast<String, dynamic>();
                final title = keys
                    .map((key) => map[key]?.toString() ?? '')
                    .firstWhere((value) => value.isNotEmpty, orElse: () => '');
                return ExpenseFilterOption(
                  id: (map['id'] as num?)?.toInt() ?? 0,
                  title: title,
                );
              })
              .where((option) => option.id > 0)
              .toList();
      return (
        projects: options(responses[0], ['title', 'name']),
        categories: options(responses[1], ['title', 'name']),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<TaskReportPage> getTaskReports({
    int page = 1,
    TaskReportFilter filter = TaskReportFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.reportsTasks,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._taskFilterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => TaskReportModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<PayrollReportPage> getPayrollReports({
    int page = 1,
    String search = '',
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.reportsPayrolls,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          if (search.trim().isNotEmpty) 'search': search.trim(),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => PayrollReportModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [TaskReportFilter] → `GET /reports/tasks/` query paramlari (faqat
  /// to'ldirilganlari).
  Map<String, dynamic> _taskFilterParams(TaskReportFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.createdFrom != null)
      'created_at_min': f.createdFrom!.toIso8601String(),
    if (f.createdTo != null) 'created_at_max': f.createdTo!.toIso8601String(),
    if (f.projectIds.isNotEmpty) 'project': f.projectIds.join(','),
    if (f.assigneeIds.isNotEmpty) 'assignee': f.assigneeIds.join(','),
    if (f.authorIds.isNotEmpty) 'created_by': f.authorIds.join(','),
    if (f.priority?.apiValue != null) 'priority': f.priority!.apiValue,
    if (f.status?.apiValue != null) 'status': f.status!.apiValue,
    if (f.types.isNotEmpty)
      'type': f.types.map((e) => e.apiValue).join(','),
    if (f.sprints.isNotEmpty) 'sprint': f.sprints.join(','),
    if (f.positionIds.isNotEmpty) 'position': f.positionIds.join(','),
    if (f.priceFrom != null) 'price_min': f.priceFrom,
    if (f.priceTo != null) 'price_max': f.priceTo,
    if (f.penaltyFrom != null) 'penalty_min': f.penaltyFrom,
    if (f.penaltyTo != null) 'penalty_max': f.penaltyTo,
    if (f.reopenedFrom != null) 'reopened_min': f.reopenedFrom,
    if (f.reopenedTo != null) 'reopened_max': f.reopenedTo,
  };

  Map<String, dynamic> _expenseFilterParams(ExpenseReportFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.userIds.isNotEmpty) 'user': f.userIds.join(','),
    if (f.accountantIds.isNotEmpty) 'accountant': f.accountantIds.join(','),
    if (f.projectIds.isNotEmpty) 'project': f.projectIds.join(','),
    if (f.categoryIds.isNotEmpty) 'expense_category': f.categoryIds.join(','),
    if (f.paymentMethods.isNotEmpty)
      'payment_method': f.paymentMethods
          .map((e) => e.apiValue)
          .whereType<String>()
          .join(','),
    if (f.statuses.isNotEmpty)
      'status': f.statuses.map((e) => e.apiValue).whereType<String>().join(','),
    if (f.types.isNotEmpty)
      'type': f.types.map((e) => e.apiValue).whereType<String>().join(','),
    if (f.amountFrom != null) 'amount_min': f.amountFrom,
    if (f.amountTo != null) 'amount_max': f.amountTo,
    if (f.createdFrom != null)
      'created_at_min': f.createdFrom!.toIso8601String(),
    if (f.createdTo != null) 'created_at_max': f.createdTo!.toIso8601String(),
    if (f.paidFrom != null) 'paid_at_min': f.paidFrom!.toIso8601String(),
    if (f.paidTo != null) 'paid_at_max': f.paidTo!.toIso8601String(),
    if (f.confirmedFrom != null)
      'confirmed_at_min': f.confirmedFrom!.toIso8601String(),
    if (f.confirmedTo != null)
      'confirmed_at_max': f.confirmedTo!.toIso8601String(),
    if (f.cancelledFrom != null)
      'cancelled_at_min': f.cancelledFrom!.toIso8601String(),
    if (f.cancelledTo != null)
      'cancelled_at_max': f.cancelledTo!.toIso8601String(),
  };
}
