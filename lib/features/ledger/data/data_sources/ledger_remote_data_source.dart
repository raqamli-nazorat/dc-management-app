import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/entities/ledger_filter.dart';
import '../models/ledger_model.dart';

/// Moliya tarixi backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class LedgerRemoteDataSource {
  Future<LedgerPage> getLedger({int page, LedgerFilter filter});

  Future<LedgerEntry> getLedgerEntry(int id);
}

class LedgerRemoteDataSourceImpl implements LedgerRemoteDataSource {
  const LedgerRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<LedgerPage> getLedger({
    int page = 1,
    LedgerFilter filter = LedgerFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.ledger,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => LedgerModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<LedgerEntry> getLedgerEntry(int id) async {
    try {
      final response = await _client.get(ApiConstants.ledgerById(id));
      return LedgerModel.fromJson(
        ResponseMapper.asMap(response.data).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [LedgerFilter] → `GET /ledger/` query paramlari (faqat to'ldirilganlari).
  Map<String, dynamic> _filterParams(LedgerFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.transactionType != null)
      'transaction_type': f.transactionType!.apiValue,
    if (f.dateFrom != null) 'created_at__gte': f.dateFrom!.toIso8601String(),
    if (f.dateTo != null) 'created_at__lte': f.dateTo!.toIso8601String(),
    if (f.amountFrom != null) 'amount__gte': f.amountFrom,
    if (f.amountTo != null) 'amount__lte': f.amountTo,
  };
}
