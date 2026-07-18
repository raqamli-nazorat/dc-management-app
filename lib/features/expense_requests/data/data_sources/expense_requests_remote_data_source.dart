import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/entities/expense_request_filter.dart';
import '../models/expense_request_model.dart';

/// Xarajat so'rovlari backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class ExpenseRequestsRemoteDataSource {
  Future<ExpenseRequestPage> getExpenseRequests({
    int page,
    ExpenseRequestFilter filter,
  });

  Future<ExpenseRequest> getExpenseRequest(int id);

  Future<ExpenseRequest> payExpenseRequest(int id);

  Future<ExpenseRequest> cancelExpenseRequest(int id, String reason);
}

class ExpenseRequestsRemoteDataSourceImpl
    implements ExpenseRequestsRemoteDataSource {
  const ExpenseRequestsRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<ExpenseRequestPage> getExpenseRequests({
    int page = 1,
    ExpenseRequestFilter filter = ExpenseRequestFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.expenseRequests,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => ExpenseRequestModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ExpenseRequest> getExpenseRequest(int id) async {
    try {
      final response = await _client.get(ApiConstants.expenseRequestById(id));
      return _asRequest(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ExpenseRequest> payExpenseRequest(int id) async {
    try {
      final response = await _client.post(ApiConstants.expenseRequestPay(id));
      return _asRequest(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ExpenseRequest> cancelExpenseRequest(int id, String reason) async {
    try {
      final response = await _client.post(
        ApiConstants.expenseRequestCancel(id),
        data: {'cancel_reason': reason},
      );
      return _asRequest(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  static ExpenseRequest _asRequest(Object? data) =>
      ExpenseRequestModel.fromJson(
        ResponseMapper.asMap(data).cast<String, dynamic>(),
      );

  /// [ExpenseRequestFilter] → `GET /expense-request/` query paramlari (faqat
  /// to'ldirilganlari).
  Map<String, dynamic> _filterParams(ExpenseRequestFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.type?.apiValue != null) 'type': f.type!.apiValue,
    if (f.categoryId != null) 'expense_category': f.categoryId,
    if (f.projectId != null) 'project': f.projectId,
    if (f.amountFrom != null) 'amount__gte': f.amountFrom,
    if (f.amountTo != null) 'amount__lte': f.amountTo,
    if (f.createdFrom != null)
      'created_at__gte': f.createdFrom!.toIso8601String(),
    if (f.createdTo != null) 'created_at__lte': f.createdTo!.toIso8601String(),
    if (f.paidFrom != null) 'paid_at__gte': f.paidFrom!.toIso8601String(),
    if (f.paidTo != null) 'paid_at__lte': f.paidTo!.toIso8601String(),
    if (f.confirmedFrom != null)
      'confirmed_at__gte': f.confirmedFrom!.toIso8601String(),
    if (f.confirmedTo != null)
      'confirmed_at__lte': f.confirmedTo!.toIso8601String(),
  };
}
