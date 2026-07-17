import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/entities/payroll_filter.dart';
import '../models/payroll_model.dart';

/// Ish haqi backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class PayrollRemoteDataSource {
  Future<PayrollPage> getPayrolls({int page, PayrollFilter filter});

  Future<Payroll> getPayroll(int id);

  Future<void> confirmPayrolls(List<int> ids);
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  const PayrollRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<PayrollPage> getPayrolls({
    int page = 1,
    PayrollFilter filter = PayrollFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.payroll,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => PayrollModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<Payroll> getPayroll(int id) async {
    try {
      final response = await _client.get(ApiConstants.payrollById(id));
      return PayrollModel.fromJson(
        ResponseMapper.asMap(response.data).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> confirmPayrolls(List<int> ids) async {
    try {
      await _client.post(
        ApiConstants.payrollConfirm,
        data: {'payroll_ids': ids},
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [PayrollFilter] → `GET /payroll/` query paramlari (faqat to'ldirilganlari).
  Map<String, dynamic> _filterParams(PayrollFilter f) {
    String date(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
    return {
      if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
      if (f.month != null)
        'month': date(DateTime(f.month!.year, f.month!.month)),
      if (f.createdFrom != null) 'month__gte': date(f.createdFrom!),
      if (f.createdTo != null) 'month__lte': date(f.createdTo!),
      if (f.totalFrom != null) 'total_amount__gte': f.totalFrom,
      if (f.totalTo != null) 'total_amount__lte': f.totalTo,
      if (f.penaltyFrom != null) 'penalty_amount__gte': f.penaltyFrom,
      if (f.penaltyTo != null) 'penalty_amount__lte': f.penaltyTo,
    };
  }
}
