import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/entities/new_expense_request.dart';
import '../../domain/usecases/create_expense_request_usecase.dart';

part 'expense_request_create_event.dart';
part 'expense_request_create_state.dart';

/// Xarajat so'rovi yaratish bloci (`POST /expense-request/`). Validatsiya UI
/// tomonda; bloc tayyor [NewExpenseRequest]ni yuboradi va natijani emit qiladi.
class ExpenseRequestCreateBloc
    extends Bloc<ExpenseRequestCreateEvent, ExpenseRequestCreateState> {
  ExpenseRequestCreateBloc({required CreateExpenseRequestUseCase create})
    : _create = create,
      super(const ExpenseRequestCreateState()) {
    on<ExpenseRequestCreateSubmitted>(_onSubmit);
  }

  final CreateExpenseRequestUseCase _create;

  Future<void> _onSubmit(
    ExpenseRequestCreateSubmitted event,
    Emitter<ExpenseRequestCreateState> emit,
  ) async {
    if (state.status == ExpenseRequestCreateStatus.submitting) return;
    emit(state.copyWith(status: ExpenseRequestCreateStatus.submitting));
    try {
      final created = await _create(event.request);
      emit(
        state.copyWith(
          status: ExpenseRequestCreateStatus.success,
          created: created,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(
          status: ExpenseRequestCreateStatus.failure,
          failure: f,
        ),
      );
    }
  }
}
