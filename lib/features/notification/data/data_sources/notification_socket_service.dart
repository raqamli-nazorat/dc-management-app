import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/entities/notification.dart';
import '../models/notification_model.dart';
import 'notification_remote_data_source.dart';

/// Real-vaqt bildirishnomalar uchun WebSocket ulanishi.
///
/// Oqim: bir martalik ticket olinadi (`POST /notifications/tickets/`) →
/// `wss://…/ws/notifications/?ticket=…` ga ulaniladi → har xabar
/// [NotificationEntity]ga aylantirilib broadcast [stream]ga uzatiladi.
///
/// Ticket bir martalik va 60s da eskiradi — shu bois har ulanishda yangi ticket
/// olinadi. Uzilishda avtomatik qayta ulanadi (eksponensial backoff).
class NotificationSocketService {
  NotificationSocketService({
    required NotificationRemoteDataSource remote,
    required LoggerService logger,
  })  : _remote = remote,
        _logger = logger;

  final NotificationRemoteDataSource _remote;
  final LoggerService _logger;

  final StreamController<NotificationEntity> _controller =
      StreamController<NotificationEntity>.broadcast();

  /// Kelayotgan bildirishnomalar (broadcast — bir nechta tinglovchi mumkin:
  /// bloc UI ro‘yxatini yangilaydi, bootstrap lokal bildirishnoma ko‘rsatadi).
  Stream<NotificationEntity> get stream => _controller.stream;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  bool _active = false;
  int _attempt = 0;

  bool get isConnected => _channel != null;

  /// Ulanishni boshlaydi (autentifikatsiyadan keyin chaqiriladi).
  Future<void> connect() async {
    if (_active) return;
    _active = true;
    await _open();
  }

  Future<void> _open() async {
    if (!_active) return;
    try {
      final ticket = await _remote.getSocketTicket();
      final channel = WebSocketChannel.connect(
        Uri.parse(ApiConstants.notificationsSocket(ticket)),
      );
      await channel.ready;
      _channel = channel;
      _attempt = 0;
      _sub = channel.stream.listen(
        _onData,
        onError: (Object e) {
          _logger.log('WS xato: $e');
          _scheduleReconnect();
        },
        onDone: () {
          _logger.log('WS yopildi (code: ${channel.closeCode})');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
      _logger.log('WS ulandi');
    } catch (e) {
      _logger.log('WS ulanish xatosi: $e');
      _scheduleReconnect();
    }
  }

  void _onData(dynamic raw) {
    try {
      final decoded = jsonDecode(raw is String ? raw : raw.toString());
      if (decoded is Map) {
        _controller.add(
          NotificationModel.fromJson(decoded.cast<String, dynamic>()),
        );
      }
    } catch (e) {
      _logger.log('WS xabarni o‘qishda xato: $e');
    }
  }

  void _scheduleReconnect() {
    _sub?.cancel();
    _sub = null;
    _channel = null;
    if (!_active) return;
    _attempt++;
    // 2, 4, 6 … 30 soniya (maksimum bilan cheklangan).
    final seconds = (2 * _attempt).clamp(2, 30);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(Duration(seconds: seconds), _open);
  }

  /// Ulanishni to‘xtatadi (logout / background). Qayta ulanish bloklanadi.
  Future<void> disconnect() async {
    _active = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}
