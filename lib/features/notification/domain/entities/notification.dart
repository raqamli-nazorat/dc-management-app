import 'package:equatable/equatable.dart';

/// Bitta bildirishnoma — WS va FCM bir xil modeldan foydalanadi (backend doc):
/// `{ id, title, message, type, extra_data, created_at }`.
class NotificationEntity extends Equatable {
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.extraData = const {},
  });

  final int id;
  final String title;
  final String message;

  /// Xabar turi (masalan `alert`, `info`). Ikonka tanlashda ishlatiladi.
  final String type;
  final bool isRead;
  final DateTime? createdAt;

  /// Qo‘shimcha ma’lumot — deep-link uchun: `{action: open_task|open_project,
  /// task_id | project_id}`.
  final Map<String, dynamic> extraData;

  /// Deep-link amali (`open_task` | `open_project` | ...), bo‘lmasa bo‘sh.
  String get action => extraData['action']?.toString() ?? '';

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
        id: id,
        title: title,
        message: message,
        type: type,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
        extraData: extraData,
      );

  @override
  List<Object?> get props =>
      [id, title, message, type, isRead, createdAt, extraData];
}
