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
/// PIN qulfi fon timeout’iga bog‘liq: foydalanuvchi ilovani [pinLockTimeout]
/// (3 daqiqa) dan kam vaqt tark etsa — sessiya tiklanadi (PIN so‘ralmaydi);
/// undan ko‘proq bo‘lsa — PIN majburiy. Bu ham resume’da, ham sovuq
/// ishga tushirishda (bootstrap) bir xil ishlaydi.
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
    on<SessionBackgrounded>(_onBackgrounded);
    on<SessionResumed>(_onResumed);
  }

  final TokenService _tokenService;
  final StorageService _storage;

  /// Oxirgi faollik vaqtining RAM nusxasi — fonga o‘tishda disk yozuvi tugamay
  /// qolsa ham (OS isolate’ni darhol muzlatadi), bu sinxron qiymat saqlanadi.
  /// RAM jarayon o‘ldirilmaguncha yashaydi, shu sabab resume’da ishonchli.
  DateTime? _lastActiveAtMemory;

  static const Duration sessionDuration = Duration(hours: 8);

  /// Fon timeout’i: bundan ortiq tark etilsa PIN qayta so‘raladi.
  static const Duration pinLockTimeout = Duration(seconds: 6);

  bool get _hasCachedLogin {
    final username = _storage.getString(StorageKeys.loginUsername);
    return username != null && username.isNotEmpty;
  }

  bool get _hasToken {
    final token = _tokenService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Fon timeout’i tugaganmi: oxirgi faollikdan [pinLockTimeout] o‘tdimi.
  /// Belgilanmagan bo‘lsa — tugagan deb hisoblanadi (xavfsiz default → PIN).
  /// Faqat ichki: background→resume o‘tishida (`_onResumed`) va bootstrap’da.
  bool get _pinLockExpired {
    // RAM nusxasi ustun (eng yangi, race’dan xoli); bo‘lmasa diskdan (cold start).
    final lastActive = _lastActiveAtMemory ??
        DateTime.tryParse(_storage.getString(StorageKeys.lastActiveAt) ?? '');
    if (lastActive == null) return true;
    return DateTime.now().difference(lastActive) > pinLockTimeout;
  }

  Future<void> _onStarted(
    SessionStarted event,
    Emitter<SessionState> emit,
  ) async {
    if (!_hasCachedLogin) {
      emit(const SessionState.unauthenticated());
      return;
    }
    // Token bor va fon timeout’i tugamagan bo‘lsa — sessiyani tiklaymiz.
    if (_hasToken && !_pinLockExpired) {
      emit(const SessionState.authenticated());
      return;
    }
    emit(const SessionState.pinRequired());
  }

  Future<void> _onLoggedIn(
    SessionLoggedIn event,
    Emitter<SessionState> emit,
  ) async {
    await _tokenService.saveToken(event.token);
    await _touchExpiry();
    await _touchLastActive();

    final roleSelectionRequired = event.roles.length > 1;
    if (!roleSelectionRequired && event.roles.isNotEmpty) {
      await _storage.setString(StorageKeys.activeRole, event.roles.first);
    }

    emit(SessionState.authenticated(
      roles: event.roles,
      roleSelectionRequired: roleSelectionRequired,
    ));
  }

  Future<void> _onBackgrounded(
    SessionBackgrounded event,
    Emitter<SessionState> emit,
  ) async {
    // Faqat autentifikatsiyalangan sessiyada vaqt belgilash mantiqiy.
    if (!state.isAuthenticated) return;
    await _touchLastActive();
  }

  Future<void> _onResumed(
    SessionResumed event,
    Emitter<SessionState> emit,
  ) async {
    if (!state.isAuthenticated) return;
    if (_pinLockExpired) {
      emit(const SessionState.pinRequired());
    }
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

  /// Oxirgi faollik vaqtini hozirgi onga belgilaydi (fon timeout’i uchun).
  Future<void> _touchLastActive() {
    final now = DateTime.now();
    // Sinxron — OS isolate’ni muzlatishidan oldin darhol yoziladi (race fix).
    _lastActiveAtMemory = now;
    // Disk — cold start (jarayon o‘ldirilgan) holati uchun persistensiya.
    return _storage.setString(StorageKeys.lastActiveAt, now.toIso8601String());
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

  /// To‘liq chiqish — login identifikatori, rol, PIN uzunligi va fon vaqti
  /// ham tozalanadi.
  Future<void> _clearAll() async {
    await _clearTokens();
    await _storage.remove(StorageKeys.loginUsername);
    await _storage.remove(StorageKeys.activeRole);
    await _storage.remove(StorageKeys.pinLength);
    await _storage.remove(StorageKeys.lastActiveAt);
    _lastActiveAtMemory = null;
  }
}
