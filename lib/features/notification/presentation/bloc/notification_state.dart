part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.items = const [],
    this.failure,
  });

  final NotificationStatus status;
  final List<NotificationEntity> items;
  final Failure? failure;

  int get unreadCount => items.where((e) => !e.isRead).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? items,
    Failure? failure,
  }) =>
      NotificationState(
        status: status ?? this.status,
        items: items ?? this.items,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, items, failure];
}
