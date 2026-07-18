import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reports/domain/entities/expense_report_filter.dart';
import '../../../reports/domain/usecases/get_expense_report_options_usecase.dart';

part 'expense_request_options_event.dart';
part 'expense_request_options_state.dart';

/// Filtr sahifasi tanlov ro'yxatlari (Loyiha + Toifa) — hisobotlardagi
/// [GetExpenseReportOptionsUseCase] qayta ishlatiladi (`/project-shorts/` +
/// `/expense-category/`).
class ExpenseRequestOptionsBloc
    extends Bloc<ExpenseRequestOptionsEvent, ExpenseRequestOptionsState> {
  ExpenseRequestOptionsBloc({
    required GetExpenseReportOptionsUseCase getOptions,
  }) : _getOptions = getOptions,
       super(const ExpenseRequestOptionsState()) {
    on<ExpenseRequestOptionsRequested>(_onRequested);
  }

  final GetExpenseReportOptionsUseCase _getOptions;

  Future<void> _onRequested(
    ExpenseRequestOptionsRequested event,
    Emitter<ExpenseRequestOptionsState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      emit(state.copyWith(loading: false, options: await _getOptions()));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}
