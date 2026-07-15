import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../tasks/domain/entities/task_form_options.dart';
import '../../../tasks/domain/usecases/get_users_usecase.dart';
import '../../domain/entities/expense_report_filter.dart';
import '../../domain/usecases/get_expense_report_options_usecase.dart';

part 'expense_reports_filter_event.dart';
part 'expense_reports_filter_state.dart';

class ExpenseReportsFilterBloc
    extends Bloc<ExpenseReportsFilterEvent, ExpenseReportsFilterState> {
  ExpenseReportsFilterBloc({
    required GetExpenseReportOptionsUseCase getOptions,
    required GetUsersUseCase getUsers,
  }) : _getOptions = getOptions,
       _getUsers = getUsers,
       super(const ExpenseReportsFilterState()) {
    on<ExpenseReportsFilterOptionsRequested>(_onRequested);
  }

  final GetExpenseReportOptionsUseCase _getOptions;
  final GetUsersUseCase _getUsers;

  Future<void> _onRequested(
    ExpenseReportsFilterOptionsRequested event,
    Emitter<ExpenseReportsFilterState> emit,
  ) async {
    emit(state.copyWith(loading: true));
    try {
      final optionsFuture = _getOptions();
      final usersFuture = _getUsers();
      emit(
        state.copyWith(
          loading: false,
          options: await optionsFuture,
          users: await usersFuture,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }
}
