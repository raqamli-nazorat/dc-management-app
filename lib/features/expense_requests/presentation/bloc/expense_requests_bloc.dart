import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/entities/expense_request_filter.dart';
import '../../domain/usecases/get_expense_requests_usecase.dart';

part 'expense_requests_event.dart';
part 'expense_requests_state.dart';

/// Xarajat so'rovlari ro'yxati bloci (`GET /expense-request/`).
class ExpenseRequestsBloc
    extends Bloc<ExpenseRequestsEvent, ExpenseRequestsState> {
  ExpenseRequestsBloc({required GetExpenseRequestsUseCase getExpenseRequests})
    : _getExpenseRequests = getExpenseRequests,
      super(const ExpenseRequestsState()) {
    on<ExpenseRequestsRequested>(_onRequested);
    on<ExpenseRequestsLoadMore>(_onLoadMore);
    on<ExpenseRequestsSearchChanged>(_onSearchChanged);
    on<ExpenseRequestsFilterChanged>(_onFilterChanged);
  }

  final GetExpenseRequestsUseCase _getExpenseRequests;

  Future<void> _onRequested(
    ExpenseRequestsRequested event,
    Emitter<ExpenseRequestsState> emit,
  ) => _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    ExpenseRequestsSearchChanged event,
    Emitter<ExpenseRequestsState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _onFilterChanged(
    ExpenseRequestsFilterChanged event,
    Emitter<ExpenseRequestsState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(
    ExpenseRequestFilter filter,
    Emitter<ExpenseRequestsState> emit,
  ) async {
    emit(
      state.copyWith(status: ExpenseRequestsStatus.loading, filter: filter),
    );
    try {
      final page = await _getExpenseRequests((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: ExpenseRequestsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: ExpenseRequestsStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    ExpenseRequestsLoadMore event,
    Emitter<ExpenseRequestsState> emit,
  ) async {
    if (state.status != ExpenseRequestsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getExpenseRequests((page: next, filter: state.filter));
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
