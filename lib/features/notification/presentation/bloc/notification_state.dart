part of 'notification_bloc.dart';

enum NotificationStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.initial,
    this.items = const [],
    this.failure,
    this.unreadTotal,
  });

  final NotificationStatus status;
  final List<NotificationEntity> items;
  final Failure? failure;
  final int? unreadTotal;

  int get unreadCount => unreadTotal ?? items.where((e) => !e.isRead).length;

  NotificationState copyWith({
    NotificationStatus? status,
    List<NotificationEntity>? items,
    Failure? failure,
    int? unreadTotal,
  }) => NotificationState(
    status: status ?? this.status,
    items: items ?? this.items,
    failure: failure,
    unreadTotal: unreadTotal ?? this.unreadTotal,
  );

  @override
  List<Object?> get props => [status, items, failure, unreadTotal];
}
