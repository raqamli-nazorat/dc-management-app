import '../entities/notification.dart';

/// Bildirishnoma domen shartnomasi.
abstract interface class NotificationRepository {
  /// Real-vaqt WebSocket oqimi — kelayotgan bildirishnomalar.
  Stream<NotificationEntity> get notificationStream;

  /// Ro‘yxat (`GET /notifications/`).
  Future<List<NotificationEntity>> getNotifications();

  /// O‘qilmaganlar soni (`GET /notifications/count/`).
  Future<int> getUnreadCount();

  /// Bittasini o‘qilgan deb belgilash (`PATCH /notifications/{id}/read/`).
  Future<void> markRead(int id);

  /// Hammasini o‘qilgan deb belgilash (`POST /notifications/read-all/`).
  Future<void> readAll();

  /// WebSocket uchun bir martalik ticket (`POST /notifications/tickets/`).
  Future<String> getSocketTicket();

  /// Qurilmani FCM token bilan ro‘yxatdan o‘tkazish
  /// (`POST /devices/register/`). [deviceType]: `ios` | `android` | `web`.
  Future<void> registerDevice({
    required String fcmToken,
    required String deviceType,
    required String deviceId,
  });
}
