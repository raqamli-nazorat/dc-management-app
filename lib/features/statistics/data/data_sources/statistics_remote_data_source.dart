import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/statistics_model.dart';

/// Statistika backend bilan to‘g‘ridan-to‘g‘ri muloqot.
abstract interface class StatisticsRemoteDataSource {
  /// Davr statistikasi (`GET /users/me/period-statistics/?months=`).
  Future<PeriodStatisticsModel> getPeriodStatistics(int months);
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  const StatisticsRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<PeriodStatisticsModel> getPeriodStatistics(int months) async {
    try {
      final response = await _client.get(
        ApiConstants.usersMePeriodStatistics,
        queryParameters: {'months': months},
      );
      return PeriodStatisticsModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
