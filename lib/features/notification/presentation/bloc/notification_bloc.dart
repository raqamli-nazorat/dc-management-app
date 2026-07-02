import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/notification_usecases.dart';

part 'notification_event.dart';
part 'notification_state.dart';

/// Bildirishnomalar ro‘yxati, o‘qish holati va real-vaqt (WebSocket) oqimini
/// boshqaradi.
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc({
    required GetNotificationsUseCase getNotifications,
    required MarkNotificationReadUseCase markRead,
    required ReadAllNotificationsUseCase readAll,
    required WatchNotificationsUseCase watch,
  })  : _getNotifications = getNotifications,
        _markRead = markRead,
        _readAll = readAll,
        super(const NotificationState()) {
    on<NotificationsRequested>(_onRequested);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationReadAllRequested>(_onReadAll);
    on<NotificationReceived>(_onReceived);

    // Real-vaqt oqimini tinglab, kelgan har bir xabarni event sifatida uzatamiz.
    _socketSub = watch().listen((n) => add(NotificationReceived(n)));
  }

  final GetNotificationsUseCase _getNotifications;
  final MarkNotificationReadUseCase _markRead;
  final ReadAllNotificationsUseCase _readAll;
  late final StreamSubscription<NotificationEntity> _socketSub;

  Future<void> _onRequested(
    NotificationsRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(status: NotificationStatus.loading));
    try {
      final items = await _getNotifications(null);
      emit(state.copyWith(status: NotificationStatus.success, items: items));
    } on Failure catch (f) {
      emit(state.copyWith(status: NotificationStatus.failure, failure: f));
    }
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationState> emit,
  ) async {
    // Optimistik yangilash — UI darhol o‘qilgan holatga o‘tadi.
    final updated = state.items
        .map((e) => e.id == event.id ? e.copyWith(isRead: true) : e)
        .toList();
    emit(state.copyWith(items: updated));
    try {
      await _markRead(event.id);
    } on Failure {
      // Xatoда jimgina qoldiramiz — keyingi refresh haqiqiy holatni tiklaydi.
    }
  }

  Future<void> _onReadAll(
    NotificationReadAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    final updated = state.items.map((e) => e.copyWith(isRead: true)).toList();
    emit(state.copyWith(items: updated));
    try {
      await _readAll(null);
    } on Failure {
      // Ignore — refresh reconciles.
    }
  }

  /// WebSocket’dan kelgan yangi bildirishnoma — ro‘yxat boshiga qo‘shiladi
  /// (id bo‘yicha takrorlanmaydi; bir xil id kelsa yangilanadi).
  void _onReceived(
    NotificationReceived event,
    Emitter<NotificationState> emit,
  ) {
    final incoming = event.notification;
    final rest = state.items.where((e) => e.id != incoming.id);
    emit(state.copyWith(
      status: NotificationStatus.success,
      items: [incoming, ...rest],
    ));
  }

  @override
  Future<void> close() {
    _socketSub.cancel();
    return super.close();
  }
}
