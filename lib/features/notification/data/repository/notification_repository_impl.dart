import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repository/notification_repository.dart';
import '../data_sources/notification_remote_data_source.dart';
import '../data_sources/notification_socket_service.dart';

/// [NotificationRepository] implementatsiyasi — `Exception` → `Failure`.
class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl(this._remote, this._socket);

  final NotificationRemoteDataSource _remote;
  final NotificationSocketService _socket;

  @override
  Stream<NotificationEntity> get notificationStream => _socket.stream;

  @override
  Future<List<NotificationEntity>> getNotifications() =>
      _guard(() => _remote.getNotifications());

  @override
  Future<int> getUnreadCount() => _guard(() => _remote.getUnreadCount());

  @override
  Future<void> markRead(int id) => _guard(() => _remote.markRead(id));

  @override
  Future<void> readAll() => _guard(() => _remote.readAll());

  @override
  Future<String> getSocketTicket() => _guard(() => _remote.getSocketTicket());

  @override
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  }) =>
      // Swagger `UserDevice`: `fcm_token`, `device_type`, `device_id`
      // (integration doc’dagi `registration_id`/`type` noto‘g‘ri edi).
      _guard(() => _remote.registerDevice({
            'fcm_token': fcmToken,
            'device_type': deviceType,
            'device_id': deviceId,
          }));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
