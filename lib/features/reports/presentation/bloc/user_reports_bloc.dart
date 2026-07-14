import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_report.dart';
import '../../domain/entities/user_report_filter.dart';
import '../../domain/usecases/get_user_reports_usecase.dart';

part 'user_reports_event.dart';
part 'user_reports_state.dart';

/// Xodimlar bo'yicha hisobot ro'yxati bloci (`GET /reports/users/`).
class UserReportsBloc extends Bloc<UserReportsEvent, UserReportsState> {
  UserReportsBloc({required GetUserReportsUseCase getUserReports})
    : _getUserReports = getUserReports,
      super(const UserReportsState()) {
    on<UserReportsRequested>(_onRequested);
    on<UserReportsLoadMore>(_onLoadMore);
    on<UserReportsSearchChanged>(_onSearchChanged);
    on<UserReportsFilterChanged>(_onFilterChanged);
  }

  final GetUserReportsUseCase _getUserReports;

  Future<void> _onRequested(
    UserReportsRequested event,
    Emitter<UserReportsState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    UserReportsSearchChanged event,
    Emitter<UserReportsState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _onFilterChanged(
    UserReportsFilterChanged event,
    Emitter<UserReportsState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(
    UserReportFilter filter,
    Emitter<UserReportsState> emit,
  ) async {
    emit(state.copyWith(status: UserReportsStatus.loading, filter: filter));
    try {
      final page = await _getUserReports((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: UserReportsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: UserReportsStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    UserReportsLoadMore event,
    Emitter<UserReportsState> emit,
  ) async {
    if (state.status != UserReportsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getUserReports((page: next, filter: state.filter));
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
