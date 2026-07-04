import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/task_model.dart';

/// Vazifalar backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks();
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      // Sahifalangan javob (`{count, next, previous, results}`) — `asList`
      // `results` ni ochib beradi.
      final response = await _client.get(ApiConstants.tasks);
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => TaskModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
