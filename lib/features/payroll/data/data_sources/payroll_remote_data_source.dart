import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/payroll.dart';
import '../models/payroll_model.dart';

/// Ish haqi backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class PayrollRemoteDataSource {
  Future<PayrollPage> getPayrolls({int page, String search});

  Future<Payroll> getPayroll(int id);

  Future<void> confirmPayrolls(List<int> ids);
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  const PayrollRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<PayrollPage> getPayrolls({int page = 1, String search = ''}) async {
    try {
      final response = await _client.get(
        ApiConstants.payroll,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          if (search.trim().isNotEmpty) 'search': search.trim(),
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
}
