import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/usecases/cancel_expense_request_usecase.dart';
import '../../domain/usecases/get_expense_request_detail_usecase.dart';
import '../../domain/usecases/pay_expense_request_usecase.dart';

part 'expense_request_detail_event.dart';
part 'expense_request_detail_state.dart';

/// Xarajat so'rovi detail + to'lov/rad etish bloci
/// (`GET /expense-request/{id}/`, `POST .../pay/`, `POST .../cancel/`).
class ExpenseRequestDetailBloc
    extends Bloc<ExpenseRequestDetailEvent, ExpenseRequestDetailState> {
  ExpenseRequestDetailBloc({
    required GetExpenseRequestDetailUseCase getRequest,
    required PayExpenseRequestUseCase payRequest,
    required CancelExpenseRequestUseCase cancelRequest,
  }) : _getRequest = getRequest,
       _payRequest = payRequest,
       _cancelRequest = cancelRequest,
       super(const ExpenseRequestDetailState()) {
    on<ExpenseRequestDetailRequested>(_onRequested);
    on<ExpenseRequestPayRequested>(_onPay);
    on<ExpenseRequestCancelRequested>(_onCancel);
  }

  final GetExpenseRequestDetailUseCase _getRequest;
  final PayExpenseRequestUseCase _payRequest;
  final CancelExpenseRequestUseCase _cancelRequest;

  Future<void> _onRequested(
    ExpenseRequestDetailRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseRequestDetailStatus.loading));
    try {
      final request = await _getRequest(event.id);
      emit(
        state.copyWith(
          status: ExpenseRequestDetailStatus.success,
          request: request,
        ),
      );
    } on Failure catch (f) {
      emit(
        state.copyWith(status: ExpenseRequestDetailStatus.failure, failure: f),
      );
    }
  }

  Future<void> _onPay(
    ExpenseRequestPayRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) => _act(emit, (id) => _payRequest(id));

  Future<void> _onCancel(
    ExpenseRequestCancelRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) => _act(emit, (id) => _cancelRequest((id: id, reason: event.reason)));

  /// Umumiy amal oqimi: endpoint yangilangan so'rovni qaytaradi — state
  /// almashtiriladi, ro'yxat reload uchun [actionDone] belgilanadi.
  Future<void> _act(
    Emitter<ExpenseRequestDetailState> emit,
    Future<ExpenseRequest> Function(int id) action,
  ) async {
    final current = state.request;
    if (current == null || state.acting) return;
    emit(state.copyWith(acting: true, actionFailure: null));
    try {
      final updated = await action(current.id);
      emit(state.copyWith(acting: false, actionDone: true, request: updated));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, actionFailure: f));
    }
  }
}
