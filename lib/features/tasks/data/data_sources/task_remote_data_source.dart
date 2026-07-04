import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/task.dart';
import '../models/task_model.dart';

/// Vazifalar backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class TaskRemoteDataSource {
  /// Bitta sahifa (`GET /tasks/?page=`).
  Future<TaskPage> getTasks({int page});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<TaskPage> getTasks({int page = 1}) async {
    try {
      // Sahifalangan javob (`{count, next, previous, results}`) — sahifa
      // raqami `page` orqali, keyingi sahifa bor-yo'qligi `next != null`.
      final response = await _client.get(
        ApiConstants.tasks,
        queryParameters: {'page': page},
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => TaskModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
