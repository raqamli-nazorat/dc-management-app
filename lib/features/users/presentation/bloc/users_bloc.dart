import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/users_filter.dart';
import '../../domain/usecases/get_app_users_usecase.dart';

part 'users_event.dart';
part 'users_state.dart';

/// Foydalanuvchilar ro'yxati bloci (`GET /users/`).
class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc({required GetAppUsersUseCase getUsers})
    : _getUsers = getUsers,
      super(const UsersState()) {
    on<UsersRequested>(_onRequested);
    on<UsersLoadMore>(_onLoadMore);
    on<UsersSearchChanged>(_onSearchChanged);
    on<UsersFilterChanged>(_onFilterChanged);
  }

  final GetAppUsersUseCase _getUsers;

  Future<void> _onRequested(UsersRequested event, Emitter<UsersState> emit) =>
      _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    UsersSearchChanged event,
    Emitter<UsersState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _onFilterChanged(
    UsersFilterChanged event,
    Emitter<UsersState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(UsersFilter filter, Emitter<UsersState> emit) async {
    emit(state.copyWith(status: UsersStatus.loading, filter: filter));
    try {
      final page = await _getUsers((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: UsersStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: UsersStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    UsersLoadMore event,
    Emitter<UsersState> emit,
  ) async {
    if (state.status != UsersStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getUsers((page: next, filter: state.filter));
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: next,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (_) {
      // Load-more xatosi ro'yxatni buzmaydi — spinnerni o'chirib qo'yamiz.
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
