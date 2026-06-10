import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/token_service.dart';

part 'session_event.dart';
part 'session_state.dart';

/// Auth / sessiya / rol holatining yagona manbasi (app-level BLoC).
///
/// Router ushbu blocning [stream]ini tinglaydi va har emissiyada redirect
/// guardini qayta hisoblaydi:
/// `splash → login (username yo‘q) → pin (username bor) → roleSelect (ko‘p rol)
/// → home`.
///
/// PIN har ilova ochilishida talab qilinadi: bootstrap saqlangan tokenga
/// ishonmaydi — keshlangan login identifikatori bo‘lsa, PIN ekraniga yo‘naltiradi.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required TokenService tokenService,
    required StorageService storage,
  })  : _tokenService = tokenService,
        _storage = storage,
        super(const SessionState.unknown()) {
    on<SessionStarted>(_onStarted);
    on<SessionLoggedIn>(_onLoggedIn);
    on<SessionRoleSelected>(_onRoleSelected);
    on<SessionAttendanceCompleted>(_onAttendanceCompleted);
    on<SessionExpired>(_onExpired);
    on<SessionLogoutRequested>(_onLogoutRequested);
    on<SessionKeepAliveRequested>(_onKeepAlive);
  }

  final TokenService _tokenService;
  final StorageService _storage;

  static const Duration sessionDuration = Duration(hours: 8);

  bool get _hasCachedLogin {
    final username = _storage.getString(StorageKeys.loginUsername);
    return username != null && username.isNotEmpty;
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    // PIN har ochilishda: token bo‘lsa ham, keshlangan login bo‘lsa PIN so‘raymiz.
    if (_hasCachedLogin) {
      emit(const SessionState.pinRequired());
      return;
    }
    emit(const SessionState.unauthenticated());
  }

  Future<void> _onLoggedIn(
    SessionLoggedIn event,
    Emitter<SessionState> emit,
  ) async {
    await _tokenService.saveToken(event.token);
    await _touchExpiry();

    final roleSelectionRequired = event.roles.length > 1;
    if (!roleSelectionRequired && event.roles.isNotEmpty) {
      await _storage.setString(StorageKeys.activeRole, event.roles.first);
    }

    emit(SessionState.authenticated(
      roles: event.roles,
      roleSelectionRequired: roleSelectionRequired,
    ));
  }

  Future<void> _onRoleSelected(
    SessionRoleSelected event,
    Emitter<SessionState> emit,
  ) async {
    await _storage.setString(StorageKeys.activeRole, event.role);
    emit(state.copyWith(roleSelectionRequired: false));
  }

  Future<void> _onAttendanceCompleted(
    SessionAttendanceCompleted event,
    Emitter<SessionState> emit,
  ) async {
    await _storage.setString(StorageKeys.attendanceDate, _todayKey());
    emit(state.copyWith(attendanceRequired: false));
  }

  Future<void> _onExpired(
    SessionExpired event,
    Emitter<SessionState> emit,
  ) async {
    await _clearTokens();
    // Username kesh saqlanadi → PIN bilan qayta kirish; bo‘lmasa login.
    emit(
      _hasCachedLogin
          ? const SessionState.pinRequired()
          : const SessionState.unauthenticated(),
    );
  }

  Future<void> _onLogoutRequested(
    SessionLogoutRequested event,
    Emitter<SessionState> emit,
  ) async {
    await _clearAll();
    emit(const SessionState.unauthenticated());
  }

  Future<void> _onKeepAlive(
    SessionKeepAliveRequested event,
    Emitter<SessionState> emit,
  ) async {
    if (!state.isAuthenticated) return;
    await _touchExpiry();
  }

  Future<void> _touchExpiry() {
    final expiresAt = DateTime.now().add(sessionDuration);
    return _storage.setString(
      StorageKeys.sessionExpiresAt,
      expiresAt.toIso8601String(),
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Faqat tokenlar — login identifikatori saqlanadi (PIN qayta kirish uchun).
  Future<void> _clearTokens() async {
    await _tokenService.clearAll();
    await _storage.remove(StorageKeys.sessionExpiresAt);
    await _storage.remove(StorageKeys.cachedUser);
  }

  /// To‘liq chiqish — login identifikatori, rol va PIN uzunligi ham tozalanadi.
  Future<void> _clearAll() async {
    await _clearTokens();
    await _storage.remove(StorageKeys.loginUsername);
    await _storage.remove(StorageKeys.activeRole);
    await _storage.remove(StorageKeys.pinLength);
  }
}
