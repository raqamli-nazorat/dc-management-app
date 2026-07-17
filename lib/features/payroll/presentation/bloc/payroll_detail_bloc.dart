import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/usecases/confirm_payroll_usecase.dart';
import '../../domain/usecases/get_payroll_detail_usecase.dart';

part 'payroll_detail_event.dart';
part 'payroll_detail_state.dart';

/// Ish haqi detail + tasdiqlash bloci (`GET /payroll/{id}/`,
/// `POST /payroll/confirm/`).
class PayrollDetailBloc extends Bloc<PayrollDetailEvent, PayrollDetailState> {
  PayrollDetailBloc({
    required GetPayrollDetailUseCase getPayroll,
    required ConfirmPayrollUseCase confirmPayroll,
  }) : _getPayroll = getPayroll,
       _confirmPayroll = confirmPayroll,
       super(const PayrollDetailState()) {
    on<PayrollDetailRequested>(_onRequested);
    on<PayrollConfirmRequested>(_onConfirm);
  }

  final GetPayrollDetailUseCase _getPayroll;
  final ConfirmPayrollUseCase _confirmPayroll;

  Future<void> _onRequested(
    PayrollDetailRequested event,
    Emitter<PayrollDetailState> emit,
  ) async {
    emit(state.copyWith(status: PayrollDetailStatus.loading));
    try {
      final payroll = await _getPayroll(event.id);
      emit(
        state.copyWith(status: PayrollDetailStatus.success, payroll: payroll),
      );
    } on Failure catch (f) {
      emit(state.copyWith(status: PayrollDetailStatus.failure, failure: f));
    }
  }

  Future<void> _onConfirm(
    PayrollConfirmRequested event,
    Emitter<PayrollDetailState> emit,
  ) async {
    final current = state.payroll;
    if (current == null || state.confirming) return;
    emit(state.copyWith(confirming: true, confirmFailure: null));
    try {
      await _confirmPayroll(current.id);
      emit(
        state.copyWith(
          confirming: false,
          confirmed: true,
          payroll: current.copyWithConfirmed(),
        ),
      );
    } on Failure catch (f) {
      emit(state.copyWith(confirming: false, confirmFailure: f));
    }
  }
}
