abstract final class StorageKeys {
  static const authToken = 'auth_token';
  static const refreshToken = 'refresh_token';
  static const cachedUser = 'cached_user';
  static const languageCode = 'language_code';
  static const onboardingCompleted = 'onboarding_completed';
  static const pendingAuthRoute = 'pending_auth_route';
  static const sessionExpiresAt = 'session_expires_at';
  static const attendanceDate = 'attendance_date';

  /// Boshlang‘ich loginda kiritilgan login identifikatori — PIN oqimida
  /// keshlangan username sifatida ishlatiladi.
  static const loginUsername = 'login_username';

  /// Tanlangan aktiv rol.
  static const activeRole = 'active_role';

  /// Boshlang‘ich loginda kiritilgan parol uzunligi — PIN ko‘rsatkichi
  /// shu uzunlikni dinamik o‘qiydi (qattiq kodlanmaydi).
  static const pinLength = 'pin_length';

  /// Ilova oxirgi marta faol bo‘lgan (fonga o‘tgan) vaqt — PIN qulfining
  /// 3 daqiqalik fon timeout’ini hisoblash uchun.
  static const lastActiveAt = 'last_active_at';

  /// Backendga oxirgi yuborilgan FCM token — takror yuborishning oldini oladi.
  static const fcmToken = 'fcm_token';

  /// Qurilmaning barqaror identifikatori (bir marta generatsiya, saqlanadi) —
  /// device register `device_id` maydoni uchun.
  static const deviceId = 'device_id';

  static const all = <String>{
    authToken,
    refreshToken,
    cachedUser,
    languageCode,
    onboardingCompleted,
    pendingAuthRoute,
    sessionExpiresAt,
    attendanceDate,
    loginUsername,
    activeRole,
    pinLength,
    lastActiveAt,
    fcmToken,
    deviceId,
  };
}
