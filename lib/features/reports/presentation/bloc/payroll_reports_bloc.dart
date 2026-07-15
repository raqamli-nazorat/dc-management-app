import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payroll_report.dart';
import '../../domain/usecases/get_payroll_reports_usecase.dart';

part 'payroll_reports_event.dart';
part 'payroll_reports_state.dart';

class PayrollReportsBloc
    extends Bloc<PayrollReportsEvent, PayrollReportsState> {
  PayrollReportsBloc({required GetPayrollReportsUseCase getPayrollReports})
    : _getPayrollReports = getPayrollReports,
      super(const PayrollReportsState()) {
    on<PayrollReportsRequested>((_, emit) => _reload(state.search, emit));
    on<PayrollReportsSearchChanged>(
      (event, emit) => _reload(event.query, emit),
    );
    on<PayrollReportsLoadMore>(_onLoadMore);
  }

  final GetPayrollReportsUseCase _getPayrollReports;

  Future<void> _reload(String search, Emitter<PayrollReportsState> emit) async {
    emit(state.copyWith(status: PayrollReportsStatus.loading, search: search));
    try {
      final page = await _getPayrollReports((page: 1, search: search));
      emit(
        state.copyWith(
          status: PayrollReportsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(status: PayrollReportsStatus.failure, failure: failure),
      );
    }
  }

  Future<void> _onLoadMore(
    PayrollReportsLoadMore event,
    Emitter<PayrollReportsState> emit,
  ) async {
    if (state.status != PayrollReportsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getPayrollReports((page: next, search: state.search));
      emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: next,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }
}
