part of 'session_bloc.dart';

sealed class SessionEvent extends Equatable {
  const SessionEvent();

  @override
  List<Object?> get props => [];
}

/// Ilova ishga tushganda saqlangan sessiyani aniqlash (bootstrap).
class SessionStarted extends SessionEvent {
  const SessionStarted();
}

/// Muvaffaqiyatli autentifikatsiya (login yoki PIN) natijasi.
/// [roles] soniga qarab rol tanlash kerakligini aniqlaydi.
class SessionLoggedIn extends SessionEvent {
  const SessionLoggedIn({required this.token, this.roles = const <String>[]});

  final String token;
  final List<String> roles;

  @override
  List<Object?> get props => [token, roles];
}

/// Bir nechta roldan biri tanlandi.
class SessionRoleSelected extends SessionEvent {
  const SessionRoleSelected(this.role);

  final String role;

  @override
  List<Object?> get props => [role];
}

/// `GET /users/me/` javobidagi `active_role` bilan sessiyani sinxronlash —
/// backend tomonda faol rol o‘zgargan bo‘lishi mumkin (login/rol tanlashdan
/// keyin ham), shu sabab profil har yuklanganda tekshiriladi.
class SessionActiveRoleSynced extends SessionEvent {
  const SessionActiveRoleSynced(this.role);

  final String role;

  @override
  List<Object?> get props => [role];
}

/// Bugungi davomat topshirildi (eski oqim — mosligi uchun).
class SessionAttendanceCompleted extends SessionEvent {
  const SessionAttendanceCompleted();
}

/// Sessiya majburan tugadi (401 interceptor) — username kesh saqlanadi,
/// PIN ekraniga qaytaradi.
class SessionExpired extends SessionEvent {
  const SessionExpired();
}

/// Foydalanuvchi o‘zi chiqdi / hisobni almashtirdi — hammasi tozalanadi (login).
class SessionLogoutRequested extends SessionEvent {
  const SessionLogoutRequested();
}

/// Faollikda sessiya muddatini oldinga surish.
class SessionKeepAliveRequested extends SessionEvent {
  const SessionKeepAliveRequested();
}

/// Ilova fonga o‘tdi — fon timeout’i uchun vaqt belgilanadi.
class SessionBackgrounded extends SessionEvent {
  const SessionBackgrounded();
}

/// Ilova foreground’ga qaytdi — fon timeout’i tekshiriladi (PIN qulfi).
class SessionResumed extends SessionEvent {
  const SessionResumed();
}
