import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_report.dart';
import '../../domain/entities/expense_report_filter.dart';
import '../../domain/usecases/get_expense_reports_usecase.dart';

part 'expense_reports_event.dart';
part 'expense_reports_state.dart';

class ExpenseReportsBloc
    extends Bloc<ExpenseReportsEvent, ExpenseReportsState> {
  ExpenseReportsBloc({required GetExpenseReportsUseCase getExpenseReports})
    : _getExpenseReports = getExpenseReports,
      super(const ExpenseReportsState()) {
    on<ExpenseReportsRequested>((_, emit) => _reload(state.filter, emit));
    on<ExpenseReportsSearchChanged>(
      (event, emit) => _reload(state.filter.copyWithSearch(event.query), emit),
    );
    on<ExpenseReportsFilterChanged>(
      (event, emit) => _reload(event.filter, emit),
    );
    on<ExpenseReportsLoadMore>(_onLoadMore);
  }

  final GetExpenseReportsUseCase _getExpenseReports;

  Future<void> _reload(
    ExpenseReportFilter filter,
    Emitter<ExpenseReportsState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseReportsStatus.loading, filter: filter));
    try {
      final page = await _getExpenseReports((page: 1, filter: filter));
      emit(
        state.copyWith(
          status: ExpenseReportsStatus.success,
          items: page.items,
          page: 1,
          hasReachedMax: !page.hasMore,
          isLoadingMore: false,
        ),
      );
    } on Failure catch (failure) {
      emit(
        state.copyWith(status: ExpenseReportsStatus.failure, failure: failure),
      );
    }
  }

  Future<void> _onLoadMore(
    ExpenseReportsLoadMore event,
    Emitter<ExpenseReportsState> emit,
  ) async {
    if (state.status != ExpenseReportsStatus.success ||
        state.hasReachedMax ||
        state.isLoadingMore) {
      return;
    }
    emit(state.copyWith(isLoadingMore: true));
    try {
      final next = state.page + 1;
      final page = await _getExpenseReports((page: next, filter: state.filter));
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
