import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/entities/ledger_filter.dart';
import '../../domain/usecases/get_ledger_usecase.dart';

part 'ledger_event.dart';
part 'ledger_state.dart';

/// Moliya tarixi ro'yxati bloci (`GET /ledger/`).
class LedgerBloc extends Bloc<LedgerEvent, LedgerState> {
  LedgerBloc({required GetLedgerUseCase getLedger})
    : _getLedger = getLedger,
      super(const LedgerState()) {
    on<LedgerRequested>(_onRequested);
    on<LedgerLoadMore>(_onLoadMore);
    on<LedgerSearchChanged>(_onSearchChanged);
    on<LedgerFilterChanged>(_onFilterChanged);
  }

  final GetLedgerUseCase _getLedger;

  Future<void> _onRequested(LedgerRequested event, Emitter<LedgerState> emit) =>
      _reload(state.filter, emit);

  Future<void> _onSearchChanged(
    LedgerSearchChanged event,
    Emitter<LedgerState> emit,
  ) => _reload(state.filter.copyWithSearch(event.query), emit);

  Future<void> _onFilterChanged(
    LedgerFilterChanged event,
    Emitter<LedgerState> emit,
  ) => _reload(event.filter, emit);

  Future<void> _reload(LedgerFilter filter, Emitter<LedgerState> emit) async {
    emit(state.copyWith(status: LedgerStatus.loading, filter: filter));
    try {
      final page = await _getLedger((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: LedgerStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: LedgerStatus.failure, failure: f));
    }
  }

  Future<void> _onLoadMore(
    LedgerLoadMore event,
    Emitter<LedgerState> emit,
  ) async {
    if (state.status != LedgerStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getLedger((page: next, filter: state.filter));
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
