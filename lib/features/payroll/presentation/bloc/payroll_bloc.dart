import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/usecases/get_payrolls_usecase.dart';

part 'payroll_event.dart';
part 'payroll_state.dart';

/// Ish haqi ro'yxati bloci (`GET /payroll/`).
class PayrollBloc extends Bloc<PayrollEvent, PayrollState> {
  PayrollBloc({required GetPayrollsUseCase getPayrolls})
    : _getPayrolls = getPayrolls,
      super(const PayrollState()) {
    on<PayrollRequested>(_onRequested);
    on<PayrollLoadMore>(_onLoadMore);
    on<PayrollSearchChanged>(_onSearchChanged);
  }

  final GetPayrollsUseCase _getPayrolls;

  Future<void> _onRequested(
    PayrollRequested event,
    Emitter<PayrollState> emit,
  ) => _reload(state.search, emit);

  Future<void> _onSearchChanged(
    PayrollSearchChanged event,
    Emitter<PayrollState> emit,
  ) => _reload(event.query, emit);

  Future<void> _reload(String search, Emitter<PayrollState> emit) async {
    emit(state.copyWith(status: PayrollStatus.loading, search: search));
    try {
      final page = await _getPayrolls((page: 1, search: search));
      emit(
        state.copyWith(
          status: PayrollStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: PayrollStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    PayrollLoadMore event,
    Emitter<PayrollState> emit,
  ) async {
    if (state.status != PayrollStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getPayrolls((page: next, search: state.search));
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
