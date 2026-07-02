import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/widgets.dart';

import '../config/routes/coordinator.dart';
import '../config/routes/entity/routes.dart';
import '../core/constants/storage_keys.dart';
import '../core/services/push_notification_service.dart';
import '../core/services/storage_service.dart';
import '../features/notification/data/data_sources/notification_socket_service.dart';
import '../features/notification/domain/usecases/notification_usecases.dart';
import '../firebase_options.dart';
import '../injection_container.dart';
import 'bloc/session_bloc.dart';

Future<void> bootstrap(Widget Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase + FCM background handler (runApp’dan oldin majburiy) ────────
  // if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  // }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await configureDependencies();

  // Resolve persisted session before first frame so the router has a
  // concrete status (authenticated / unauthenticated) to act on.
  final session = getIt<SessionBloc>()..add(const SessionStarted());
  await session.stream.firstWhere((state) => state.isResolved);

  // ── Push xizmatini ulash ────────────────────────────────────────────────
  final push = getIt<PushNotificationService>();
  push.onToken = (token) async {
    // Qurilmani FCM token bilan ro‘yxatdan o‘tkazish (`POST /devices/register/`).
    final deviceId = await _deviceId(getIt<StorageService>());
    await getIt<RegisterDeviceUseCase>()(
      RegisterDeviceParams(
        fcmToken: token,
        deviceType: _deviceType(),
        deviceId: deviceId,
      ),
    );
  };
  push.onOpen = (_) {
    // Bosilganda bildirishnomalar ekraniga o‘tish. Birinchi kadrdan keyin —
    // terminated holatida router hali biriktirilmagan bo‘lishi mumkin.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppRouter>().router.pushNamed(Routes.notifications.name);
    });
  };
  // ── Real-vaqt WebSocket ulanishi ─────────────────────────────────────────
  final socket = getIt<NotificationSocketService>();
  // WS orqali kelgan xabarni lokal bildirishnoma sifatida ko‘rsatamiz — ilova
  // ochiq bo‘lganda ham foydalanuvchi ko‘radi (ro‘yxatni bloc yangilaydi).
  socket.stream.listen(
    (n) => push.showLocalNotification(
      title: n.title,
      body: n.message,
      data: n.extraData,
    ),
  );

  // Sessiya holatiga qarab: authenticated → token + WS ulash; aks holda uzish.
  // (register va ticket jwtAuth talab qiladi — token cold start’da bo‘lmasligi
  // mumkin, shu bois har autentifikatsiyada qayta bajariladi.)
  Future<void> applySession(SessionState s) async {
    if (s.isAuthenticated) {
      await push.syncToken();
      await socket.connect();
    } else {
      await socket.disconnect();
    }
  }

  if (session.state.isAuthenticated) unawaited(applySession(session.state));
  session.stream.listen(applySession);

  runApp(builder());

  // UI ko‘rsatilgach initsializatsiya — birinchi kadrni bloklamaydi.
  unawaited(push.initialize());
}

/// Platforma → backend `device_type` enumi (`ios` | `android` | `web`).
String _deviceType() {
  if (kIsWeb) return 'web';
  if (Platform.isIOS) return 'ios';
  return 'android';
}

/// Barqaror qurilma identifikatori — bir marta generatsiya qilinib saqlanadi
/// (o‘rnatish davomida o‘zgarmaydi).
Future<String> _deviceId(StorageService storage) async {
  final existing = storage.getString(StorageKeys.deviceId);
  if (existing != null && existing.isNotEmpty) return existing;
  final random = Random.secure();
  final id = List.generate(
    16,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await storage.setString(StorageKeys.deviceId, id);
  return id;
}
