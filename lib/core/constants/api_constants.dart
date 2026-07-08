abstract final class ApiConstants {
  static const baseUrl = 'https://backend.raqamlinazorat.uz/api';

  /// Real-vaqt bildirishnomalar uchun WebSocket ildizi (https → wss).
  static const wsBaseUrl = 'wss://backend.raqamlinazorat.uz';

  // ── Auth ──────────────────────────────────────────────────────────────
  static const login = '/auth/login/';
  static const refresh = '/auth/refresh/';

  // ── Profile ───────────────────────────────────────────────────────────
  static const usersMe = '/users/me/';
  static const usersMeChangePassword = '/users/me/change-password/';

  // ── Statistics (bosh sahifa grafiklari) ───────────────────────────────
  static const usersMePeriodStatistics = '/users/me/period-statistics/';
  static const usersMeEfficiency = '/users/me/efficiency/';

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

  // ── Tasks ─────────────────────────────────────────────────────────────
  static const tasks = '/tasks/';

  /// Lavozimlar — vazifa "Kimlar uchun" tanlovi (`GET /applications/positions/`).
  static const positions = '/applications/positions/';

  /// Qisqa loyihalar ro‘yxati — vazifa "Loyiha" tanlovi (`GET /project-shorts/`).
  static const projectShorts = '/project-shorts/';

  /// Bitta loyiha to‘liq ma’lumoti — ishtirokchilar (Topshiruvchi tanlovi):
  /// `GET /projects/{id}/`.
  static String projectById(int id) => '/projects/$id/';

  /// Vazifa faylini biriktirish (multipart `{task, file}`):
  /// `POST /task-attachments/`.
  static const taskAttachments = '/task-attachments/';

  // ── Meetings ──────────────────────────────────────────────────────────
  static const meetings = '/meetings/';

  /// Bitta yig‘ilish: `GET/PUT/PATCH/DELETE /meetings/{id}/`.
  static String meetingById(int id) => '/meetings/$id/';

  /// Yig‘ilishni yopish: `POST /meetings/{id}/close/`.
  static String meetingClose(int id) => '/meetings/$id/close/';

  // ── Meeting attendance (qatnashuv) ────────────────────────────────────
  /// Ro‘yxat + filtr: `GET /meeting-attendance/?meeting=&user=&is_attended=`.
  static const meetingAttendance = '/meeting-attendance/';

  /// Bitta qatnashuv yozuvi: `GET/PATCH /meeting-attendance/{id}/`
  /// (qatnashmaslik sababi shu yerga `absence_reason` bilan PATCH qilinadi).
  static String meetingAttendanceById(int id) => '/meeting-attendance/$id/';
}
