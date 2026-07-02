import '../../domain/entities/notification.dart';

/// [NotificationEntity] JSON serializatsiyasi. WS to‘g‘ridan-to‘g‘ri shu
/// modelni, FCM esa `data['payload']` ichida JSON-string sifatida yuboradi
/// (dekodlangach shu factory ishlatiladi). Parsing bardoshli.
class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.isRead,
    required super.createdAt,
    super.extraData,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return '';
    }

    bool readFlag() {
      for (final k in ['is_read', 'read', 'seen', 'is_seen']) {
        final v = json[k];
        if (v is bool) return v;
        if (v is String) return v.toLowerCase() == 'true';
      }
      return false;
    }

    final extra = json['extra_data'];

    return NotificationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: pick(['title', 'header', 'name', 'subject']),
      message: pick(['message', 'body', 'description', 'text', 'content']),
      type: pick(['type', 'category', 'kind']),
      isRead: readFlag(),
      createdAt: DateTime.tryParse(
        pick(['created_at', 'created', 'timestamp', 'date', 'date_created']),
      ),
      extraData: extra is Map ? extra.cast<String, dynamic>() : const {},
    );
  }
}
