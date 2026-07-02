import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repository/notification_repository.dart';

/// Bildirishnomalar ro‘yxatini olish.
class GetNotificationsUseCase implements UseCase<List<NotificationEntity>, void> {
  const GetNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<List<NotificationEntity>> call(void params) =>
      _repository.getNotifications();
}

/// Real-vaqt WebSocket oqimini tinglash.
class WatchNotificationsUseCase {
  const WatchNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  Stream<NotificationEntity> call() => _repository.notificationStream;
}

/// O‘qilmaganlar sonini olish (main_page ikonkasi badge’i uchun).
class GetUnreadCountUseCase implements UseCase<int, void> {
  const GetUnreadCountUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<int> call(void params) => _repository.getUnreadCount();
}

/// Bitta bildirishnomani o‘qilgan deb belgilash.
class MarkNotificationReadUseCase implements UseCase<void, int> {
  const MarkNotificationReadUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<void> call(int id) => _repository.markRead(id);
}

/// Hammasini o‘qilgan deb belgilash.
class ReadAllNotificationsUseCase implements UseCase<void, void> {
  const ReadAllNotificationsUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<void> call(void params) => _repository.readAll();
}

/// Qurilmani ro‘yxatdan o‘tkazish parametrlari.
class RegisterDeviceParams {
  const RegisterDeviceParams({
    required this.fcmToken,
    required this.deviceType,
    required this.deviceId,
  });

  final String fcmToken;

  /// `ios` | `android` | `web`.
  final String deviceType;
  final String deviceId;
}

/// Qurilmani FCM token bilan backendda ro‘yxatdan o‘tkazish.
class RegisterDeviceUseCase implements UseCase<void, RegisterDeviceParams> {
  const RegisterDeviceUseCase(this._repository);
  final NotificationRepository _repository;

  @override
  Future<void> call(RegisterDeviceParams params) => _repository.registerDevice(
        fcmToken: params.fcmToken,
        deviceType: params.deviceType,
        deviceId: params.deviceId,
      );
}
