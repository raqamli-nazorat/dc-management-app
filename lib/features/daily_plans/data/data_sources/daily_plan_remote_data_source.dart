import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../models/daily_plan_model.dart';

abstract interface class DailyPlanRemoteDataSource {
  Future<List<DailyPlanModel>> getPlans();
  Future<DailyPlanModel> createPlan(DailyPlanInput input);
  Future<DailyPlanModel> updatePlan(int id, DailyPlanInput input);
  Future<void> deletePlan(int id);
  Future<DailyPlanItemModel> createItem(int planId, String title);
  Future<DailyPlanItemModel> updateItem(
    DailyPlanItem item, {
    String? title,
    bool? isDone,
  });
}

class DailyPlanRemoteDataSourceImpl implements DailyPlanRemoteDataSource {
  const DailyPlanRemoteDataSourceImpl(this._client);
  final DioClient _client;

  @override
  Future<List<DailyPlanModel>> getPlans() async {
    try {
      final response = await _client.get(
        ApiConstants.todos,
        queryParameters: {'ordering': '-created_at'},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((item) => DailyPlanModel.fromJson(item.cast<String, dynamic>()))
          .toList();
    } on DioException catch (error) {
      throw ResponseMapper.mapDioException(error);
    }
  }

  @override
  Future<DailyPlanModel> createPlan(DailyPlanInput input) => _planRequest(
    () => _client.post(ApiConstants.todos, data: _planData(input)),
  );

  @override
  Future<DailyPlanModel> updatePlan(int id, DailyPlanInput input) =>
      _planRequest(
        () => _client.patch(ApiConstants.todoById(id), data: _planData(input)),
      );

  @override
  Future<void> deletePlan(int id) async {
    try {
      await _client.delete(ApiConstants.todoById(id));
    } on DioException catch (error) {
      throw ResponseMapper.mapDioException(error);
    }
  }

  @override
  Future<DailyPlanItemModel> createItem(int planId, String title) =>
      _itemRequest(
        () => _client.post(
          ApiConstants.todoItems,
          data: {'todo': planId, 'title': title},
        ),
      );

  @override
  Future<DailyPlanItemModel> updateItem(
    DailyPlanItem item, {
    String? title,
    bool? isDone,
  }) {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (isDone != null) data['is_done'] = isDone;
    return _itemRequest(
      () => _client.patch(ApiConstants.todoItemById(item.id), data: data),
    );
  }

  Future<DailyPlanModel> _planRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return DailyPlanModel.fromJson(
        ResponseMapper.asMap((await request()).data),
      );
    } on DioException catch (error) {
      throw ResponseMapper.mapDioException(error);
    }
  }

  Future<DailyPlanItemModel> _itemRequest(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return DailyPlanItemModel.fromJson(
        ResponseMapper.asMap((await request()).data),
      );
    } on DioException catch (error) {
      throw ResponseMapper.mapDioException(error);
    }
  }

  Map<String, dynamic> _planData(DailyPlanInput input) {
    final data = <String, dynamic>{
      'title': input.title.trim(),
      'color': input.color.name,
    };
    if (input.isDone != null) data['is_done'] = input.isDone;
    return data;
  }
}
