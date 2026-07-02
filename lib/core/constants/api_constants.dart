abstract final class ApiConstants {
  static const baseUrl = 'https://backend.raqamlinazorat.uz/api';

  /// Real-vaqt bildirishnomalar uchun WebSocket ildizi (https → wss).
  static const wsBaseUrl = 'wss://backend.raqamlinazorat.uz';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/auth/login/';
  static const refresh = '/auth/refresh/';

  // ── Profile ───────────────────────────────────────────────────────────
  static const usersMe = '/users/me/';
  static const usersMeChangePassword = '/users/me/change_password/';

  // ── Notifications ─────────────────────────────────────────────────────
  static const notifications = '/notifications/';
  static const notificationsCount = '/notifications/count/';
  static const notificationsReadAll = '/notifications/read-all/';
  static const notificationsTickets = '/notifications/tickets/';

  /// Bitta bildirishnomani o‘qilgan deb belgilash: `/notifications/{id}/read/`.
  static String notificationRead(int id) => '/notifications/$id/read/';

  /// Bildirishnoma WebSocket ulanish URL’i (bir martalik ticket bilan).
  static String notificationsSocket(String ticket) =>
      '$wsBaseUrl/ws/notifications/?ticket=$ticket';

  // ── Device (FCM) ──────────────────────────────────────────────────────
  /// Qurilmani FCM token bilan ro‘yxatdan o‘tkazish (`POST`).
  static const devicesRegister = '/devices/register/';
}
