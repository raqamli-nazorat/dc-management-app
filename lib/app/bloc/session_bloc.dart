import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/access/role_type.dart';
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
/// tanlangan vaqtdan kam vaqt tark etsa — sessiya tiklanadi (PIN so‘ralmaydi);
/// undan ko‘proq bo‘lsa — PIN majburiy. Bu ham resume’da, ham sovuq
/// ishga tushirishda (bootstrap) bir xil ishlaydi.
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  SessionBloc({
    required TokenService tokenService,
    required StorageService storage,
  }) : _tokenService = tokenService,
       _storage = storage,
       super(const SessionState.unknown()) {
    on<SessionStarted>(_onStarted);
    on<SessionLoggedIn>(_onLoggedIn);
    on<SessionRoleSelected>(_onRoleSelected);
    on<SessionActiveRoleSynced>(_onActiveRoleSynced);
    on<SessionAttendanceCompleted>(_onAttendanceCompleted);
    on<SessionExpired>(_onExpired);
    on<SessionLogoutRequested>(_onLogoutRequested);
    on<SessionKeepAliveRequested>(_onKeepAlive);
    on<SessionBackgrounded>(_onBackgrounded);
    on<SessionResumed>(_onResumed);
    on<SessionAutoLockChanged>(_onAutoLockChanged);
  }

  final TokenService _tokenService;
  final StorageService _storage;

  /// Oxirgi faollik vaqtining RAM nusxasi — fonga o‘tishda disk yozuvi tugamay
  /// qolsa ham (OS isolate’ni darhol muzlatadi), bu sinxron qiymat saqlanadi.
  /// RAM jarayon o‘ldirilmaguncha yashaydi, shu sabab resume’da ishonchli.
  DateTime? _lastActiveAtMemory;

  static const Duration sessionDuration = Duration(hours: 8);

  /// Figma’dagi timeout variantlari.
  static const autoLockTimeouts = <Duration>[
    Duration.zero,
    Duration(minutes: 1),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
    Duration(hours: 1),
  ];

  static const defaultPinLockTimeout = Duration(hours: 1);

  /// Tanlangan fon timeout’i. Noto‘g‘ri yoki eski qiymat xavfsiz defaultga
  /// qaytadi.
  Duration get pinLockTimeout {
    final seconds = int.tryParse(
      _storage.getString(StorageKeys.pinLockTimeout) ?? '',
    );
    final selected = seconds == null ? null : Duration(seconds: seconds);
    return autoLockTimeouts.contains(selected)
        ? selected!
        : defaultPinLockTimeout;
  }

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
    final lastActive =
        _lastActiveAtMemory ??
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
      emit(
        SessionState.authenticated(
          activeRole: _storage.getString(StorageKeys.activeRole),
          autoLockTimeout: pinLockTimeout,
        ),
      );
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
    final activeRole = roleSelectionRequired || event.roles.isEmpty
        ? null
        : event.roles.first;
    if (activeRole != null) {
      await _storage.setString(StorageKeys.activeRole, activeRole);
    }

    emit(
      SessionState.authenticated(
        roles: event.roles,
        roleSelectionRequired: roleSelectionRequired,
        activeRole: activeRole,
        autoLockTimeout: pinLockTimeout,
      ),
    );
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

  Future<void> _onAutoLockChanged(
    SessionAutoLockChanged event,
    Emitter<SessionState> emit,
  ) async {
    if (!autoLockTimeouts.contains(event.timeout)) return;
    await _storage.setString(
      StorageKeys.pinLockTimeout,
      event.timeout.inSeconds.toString(),
    );
    emit(state.copyWith(autoLockTimeout: event.timeout));
  }

  Future<void> _onRoleSelected(
    SessionRoleSelected event,
    Emitter<SessionState> emit,
  ) async {
    await _storage.setString(StorageKeys.activeRole, event.role);
    emit(state.copyWith(roleSelectionRequired: false, activeRole: event.role));
  }

  /// `GET /users/me/` javobi autoritativ — token bilan kelgan/tanlangan
  /// roldan farqli bo‘lsa ham (masalan backend tomonda o‘zgartirilgan),
  /// shu qiymat ustun bo‘ladi.
  Future<void> _onActiveRoleSynced(
    SessionActiveRoleSynced event,
    Emitter<SessionState> emit,
  ) async {
    if (!state.isAuthenticated) return;
    if (event.role.isEmpty || event.role == state.activeRole) return;
    await _storage.setString(StorageKeys.activeRole, event.role);
    emit(state.copyWith(activeRole: event.role));
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
    await _storage.remove(StorageKeys.pinLockTimeout);
    _lastActiveAtMemory = null;
  }
}
