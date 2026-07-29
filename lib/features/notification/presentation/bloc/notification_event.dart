part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Ro‘yxatni yuklash.
class NotificationsRequested extends NotificationEvent {
  const NotificationsRequested();
}

/// Header badge uchun o'qilmaganlar sonini yuklash.
class NotificationsUnreadCountRequested extends NotificationEvent {
  const NotificationsUnreadCountRequested();
}

/// Bittasini o‘qilgan deb belgilash.
class NotificationMarkedRead extends NotificationEvent {
  const NotificationMarkedRead(this.id);
  final int id;

  @override
  List<Object?> get props => [id];
}

/// Hammasini o‘qilgan deb belgilash.
class NotificationReadAllRequested extends NotificationEvent {
  const NotificationReadAllRequested();
}

/// WebSocket orqali yangi bildirishnoma keldi (real-vaqt).
class NotificationReceived extends NotificationEvent {
  const NotificationReceived(this.notification);
  final NotificationEntity notification;

  @override
  List<Object?> get props => [notification];
}
