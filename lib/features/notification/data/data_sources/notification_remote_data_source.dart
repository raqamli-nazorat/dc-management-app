import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> getUnreadCount();
  Future<void> markRead(int id);
  Future<void> readAll();

  /// WebSocket uchun bir martalik ticket oladi (`POST /notifications/tickets/`).
  Future<String> getSocketTicket();
  Future<void> registerDevice(Map<String, dynamic> body);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  const NotificationRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _client.get(ApiConstants.notifications);
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => NotificationModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<int> getUnreadCount() async {
    try {
      final response = await _client.get(ApiConstants.notificationsCount);
      final map = ResponseMapper.asMap(response.data);
      for (final k in ['count', 'unread', 'unread_count', 'total']) {
        final v = map[k];
        if (v is num) return v.toInt();
        if (v is String) return int.tryParse(v) ?? 0;
      }
      // Ba’zan raqamning o‘zi qaytadi.
      final raw = response.data;
      if (raw is num) return raw.toInt();
      return 0;
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> markRead(int id) async {
    try {
      await _client.patch(ApiConstants.notificationRead(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> readAll() async {
    try {
      await _client.post(ApiConstants.notificationsReadAll);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<String> getSocketTicket() async {
    try {
      final response = await _client.post(ApiConstants.notificationsTickets);
      final data = ResponseMapper.asMap(response.data);
      final ticket = data['ticket']?.toString() ?? '';
      if (ticket.isEmpty) {
        throw const ServerException('Ticket olinmadi');
      }
      return ticket;
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> registerDevice(Map<String, dynamic> body) async {
    try {
      await _client.post(ApiConstants.devicesRegister, data: body);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
