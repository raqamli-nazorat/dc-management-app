part of 'session_bloc.dart';

/// Navigatsiya guardlarini boshqaruvchi yuqori-darajali auth holati.
///
/// [unknown] — storage o‘qilgunga qadar bootstrap fazasi (splash).
/// [pinRequired] — login identifikatori keshlangan, lekin PIN bilan qayta
/// tasdiqlash kerak (har ilova ochilishida).
enum SessionStatus { unknown, unauthenticated, pinRequired, authenticated }

class SessionState extends Equatable {
  const SessionState({
    this.status = SessionStatus.unknown,
    this.roles = const <String>[],
    this.roleSelectionRequired = false,
    this.attendanceRequired = false,
    this.activeRole,
    this.autoLockTimeout,
  });

  const SessionState.unknown() : this();

  const SessionState.unauthenticated()
    : this(status: SessionStatus.unauthenticated);

  const SessionState.pinRequired() : this(status: SessionStatus.pinRequired);

  const SessionState.authenticated({
    List<String> roles = const <String>[],
    bool roleSelectionRequired = false,
    String? activeRole,
    Duration? autoLockTimeout,
  }) : this(
         status: SessionStatus.authenticated,
         roles: roles,
         roleSelectionRequired: roleSelectionRequired,
         activeRole: activeRole,
         autoLockTimeout: autoLockTimeout,
       );

  final SessionStatus status;

  /// Joriy autentifikatsiyada qaytgan rollar.
  final List<String> roles;

  /// Bir nechta rol bo‘lib, hali tanlanmaganda — rol tanlash ekraniga.
  final bool roleSelectionRequired;

  /// Davomat gate (eski oqim — guardda ishlatilmaydi, mosligi uchun saqlanadi).
  final bool attendanceRequired;

  /// Joriy tanlangan rol (xom API string) — bitta rolli login’da avtomatik,
  /// ko‘p rolli login’da `SessionRoleSelected`dan keyin to‘ldiriladi.
  final String? activeRole;

  /// Fonga o‘tgandan keyin PIN so‘raladigan vaqt.
  final Duration? autoLockTimeout;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isUnauthenticated => status == SessionStatus.unauthenticated;
  bool get isPinRequired => status == SessionStatus.pinRequired;
  bool get isResolved => status != SessionStatus.unknown;

  /// Rolga qarab UI ko‘rinishini boshqarish uchun kanonik tur
  /// ([NavPermissions] shu bilan ishlaydi).
  RoleType get roleType => RoleType.fromRaw(activeRole ?? '');

  SessionState copyWith({
    SessionStatus? status,
    List<String>? roles,
    bool? roleSelectionRequired,
    bool? attendanceRequired,
    String? activeRole,
    Duration? autoLockTimeout,
  }) {
    return SessionState(
      status: status ?? this.status,
      roles: roles ?? this.roles,
      roleSelectionRequired:
          roleSelectionRequired ?? this.roleSelectionRequired,
      attendanceRequired: attendanceRequired ?? this.attendanceRequired,
      activeRole: activeRole ?? this.activeRole,
      autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    );
  }

  @override
  List<Object?> get props => [
    status,
    roles,
    roleSelectionRequired,
    attendanceRequired,
    activeRole,
    autoLockTimeout,
  ];
}
