import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';
import '../constants/storage_keys.dart';
import 'logger_service.dart';
import 'storage_service.dart';

/// FCM background/terminated holatida keladigan xabar handleri.
///
/// Alohida isolate’da ishlaydi — shu bois Firebase’ni qaytadan initsializatsiya
/// qilish shart. `notification` payload’li xabarlarni tizim treyi avtomatik
/// ko‘rsatadi; bu yerda faqat data’ni qayta ishlash mumkin. `vm:entry-point`
/// AOT release’da tree-shaking olib tashlamasligi uchun majburiy.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  // Data-only ishlov shu yerda qo‘shiladi (masalan badge yangilash).
}

/// Push (FCM) + lokal bildirishnoma xizmati.
///
/// Barcha holatlarni qamrab oladi:
/// - **foreground** → `onMessage` + qo‘lda lokal bildirishnoma ko‘rsatiladi.
/// - **background** (tray’dan bosilish) → `onMessageOpenedApp`.
/// - **terminated** (bosib ochilgan) → `getInitialMessage`.
/// FCM token olinadi, yangilanishi kuzatiladi va [onToken] orqali backendga
/// yuboriladi. Bosilganda [onOpen] chaqiriladi (navigatsiya uchun).
class PushNotificationService {
  PushNotificationService(this._storage, this._logger);

  final StorageService _storage;
  final LoggerService _logger;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// Foreground’da lokal bildirishnomani chizadigan Android kanali. Kanal id
  /// AndroidManifest’dagi `default_notification_channel_id` bilan bir xil.
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Bildirishnomalar',
    description: 'Muhim bildirishnomalar shu kanal orqali ko‘rsatiladi.',
    importance: Importance.high,
  );

  /// Yangi/yangilangan token — backendga yuborish uchun (chaqiruvchi ulaydi).
  Future<void> Function(String token)? onToken;

  /// Bildirishnoma bosilganda — data payload bilan (navigatsiya uchun).
  void Function(Map<String, dynamic> data)? onOpen;

  bool _initialized = false;

  /// To‘liq initsializatsiya: ruxsat → lokal plagin → kanal → listenerlar →
  /// token. Bir marta bajariladi.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    // iOS foreground’da tizim banner’ini ko‘rsatish.
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    await _initLocalNotifications();

    // Foreground xabarlar — qo‘lda ko‘rsatiladi.
    FirebaseMessaging.onMessage.listen(_showForeground);
    // Tray’dan bosib ochilgan (background).
    FirebaseMessaging.onMessageOpenedApp.listen((m) => _dispatchOpen(_payload(m)));
    // Terminated holatidan bosib ochilgan.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _dispatchOpen(_payload(initial));

    // Token olish + yangilanishni kuzatish.
    await syncToken();
    _messaging.onTokenRefresh.listen((t) => _registerToken(t, force: true));
  }

  /// Joriy FCM tokenni olib backendga (agar kerak bo‘lsa) yuboradi.
  /// Autentifikatsiya bo‘lgach qayta chaqirish mumkin (login’dan keyin).
  Future<void> syncToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _logger.log('FCM token: $token');
        await _registerToken(token);
      }
    } catch (e) {
      _logger.log('FCM token olishda xato: $e');
    }
  }

  /// Chiqishda serverdagi tokenni bekor qilish uchun.
  Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      await _storage.remove(StorageKeys.fcmToken);
    } catch (_) {}
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (resp) =>
          _handlePayload(resp.payload),
    );
    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _showForeground(RemoteMessage message) {
    final payload = _payload(message);
    // Sarlavha/matn: avval `notification` bloki, bo‘lmasa `data.payload`dan.
    final title = message.notification?.title ?? payload['title']?.toString();
    final body = message.notification?.body ?? payload['message']?.toString();
    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }
    showLocalNotification(title: title, body: body, data: payload);
  }

  /// Lokal (heads-up) bildirishnoma ko‘rsatadi. WS orqali kelgan xabarlarni ham
  /// ko‘rsatish uchun ochiq (bootstrap chaqiradi).
  void showLocalNotification({
    String? title,
    String? body,
    Map<String, dynamic> data = const {},
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(1 << 31);
    _local.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  /// FCM xabaridan foydali yukni ajratadi. Backend doc: data `payload` kaliti
  /// ichida JSON-string bo‘lib keladi — dekod qilinadi; bo‘lmasa `data`ning o‘zi.
  Map<String, dynamic> _payload(RemoteMessage message) {
    final raw = message.data['payload'];
    if (raw is String && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {}
    }
    return message.data;
  }

  /// Yangi tokenni backendga yuboradi. Takrorni oldini olish uchun oxirgi
  /// yuborilgan token bilan solishtiriladi ([force] bilan majburlanadi).
  Future<void> _registerToken(String token, {bool force = false}) async {
    final last = _storage.getString(StorageKeys.fcmToken);
    if (!force && last == token) return;
    try {
      await onToken?.call(token);
      await _storage.setString(StorageKeys.fcmToken, token);
    } catch (e) {
      // Autentifikatsiya yo‘q bo‘lsa (401) — jimgina; login’dan keyin qayta.
      _logger.log('FCM tokenni ro‘yxatdan o‘tkazishda xato: $e');
    }
  }

  void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = (jsonDecode(payload) as Map).cast<String, dynamic>();
      _dispatchOpen(data);
    } catch (_) {}
  }

  void _dispatchOpen(Map<String, dynamic> data) => onOpen?.call(data);
}
