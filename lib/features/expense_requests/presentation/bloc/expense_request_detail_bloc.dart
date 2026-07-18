import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../reports/domain/entities/expense_report.dart';
import '../../domain/entities/expense_receipt.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/usecases/cancel_expense_request_usecase.dart';
import '../../domain/usecases/confirm_expense_request_usecase.dart';
import '../../domain/usecases/create_expense_receipt_usecase.dart';
import '../../domain/usecases/get_expense_receipts_usecase.dart';
import '../../domain/usecases/get_expense_request_detail_usecase.dart';
import '../../domain/usecases/pay_expense_request_usecase.dart';

part 'expense_request_detail_event.dart';
part 'expense_request_detail_state.dart';

/// Xarajat so'rovi detail + to'lov/rad etish bloci
/// (`GET /expense-request/{id}/`, `POST .../pay/`, `POST .../cancel/`,
/// `GET/POST /expense-receipt/`).
class ExpenseRequestDetailBloc
    extends Bloc<ExpenseRequestDetailEvent, ExpenseRequestDetailState> {
  ExpenseRequestDetailBloc({
    required GetExpenseRequestDetailUseCase getRequest,
    required PayExpenseRequestUseCase payRequest,
    required CancelExpenseRequestUseCase cancelRequest,
    required ConfirmExpenseRequestUseCase confirmRequest,
    required GetExpenseReceiptsUseCase getReceipts,
    required CreateExpenseReceiptUseCase createReceipt,
  }) : _getRequest = getRequest,
       _payRequest = payRequest,
       _cancelRequest = cancelRequest,
       _confirmRequest = confirmRequest,
       _getReceipts = getReceipts,
       _createReceipt = createReceipt,
       super(const ExpenseRequestDetailState()) {
    on<ExpenseRequestDetailRequested>(_onRequested);
    on<ExpenseRequestPayRequested>(_onPay);
    on<ExpenseRequestCancelRequested>(_onCancel);
    on<ExpenseRequestConfirmRequested>(_onConfirm);
  }

  final GetExpenseRequestDetailUseCase _getRequest;
  final PayExpenseRequestUseCase _payRequest;
  final CancelExpenseRequestUseCase _cancelRequest;
  final ConfirmExpenseRequestUseCase _confirmRequest;
  final GetExpenseReceiptsUseCase _getReceipts;
  final CreateExpenseReceiptUseCase _createReceipt;

  Future<void> _onRequested(
    ExpenseRequestDetailRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) async {
    emit(state.copyWith(status: ExpenseRequestDetailStatus.loading));
    try {
      final request = await _getRequest(event.id);
      // Qabul qilingan (to'langan/tasdiqlangan) so'rovda cheklar ham yuklanadi.
      final receipts = _isAccepted(request.status)
          ? await _safeReceipts(request.id)
          : const <ExpenseReceipt>[];
      emit(
        state.copyWith(
          status: ExpenseRequestDetailStatus.success,
          request: request,
          receipts: receipts,
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
  ) async {
    final current = state.request;
    if (current == null || state.acting) return;
    emit(state.copyWith(acting: true, actionFailure: null));
    try {
      // Avval cheklar yuklanadi (bo'lsa), so'ng to'lov qayd etiladi.
      for (final path in event.receiptPaths) {
        await _createReceipt((expenseId: current.id, filePath: path));
      }
      final updated = await _payRequest(current.id);
      emit(state.copyWith(acting: false, actionDone: true, request: updated));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, actionFailure: f));
    }
  }

  Future<void> _onCancel(
    ExpenseRequestCancelRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) async {
    final current = state.request;
    if (current == null || state.acting) return;
    emit(state.copyWith(acting: true, actionFailure: null));
    try {
      final updated = await _cancelRequest((
        id: current.id,
        reason: event.reason,
      ));
      emit(state.copyWith(acting: false, actionDone: true, request: updated));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, actionFailure: f));
    }
  }

  Future<void> _onConfirm(
    ExpenseRequestConfirmRequested event,
    Emitter<ExpenseRequestDetailState> emit,
  ) async {
    final current = state.request;
    if (current == null || state.acting) return;
    emit(state.copyWith(acting: true, actionFailure: null));
    try {
      final updated = await _confirmRequest(current.id);
      emit(state.copyWith(acting: false, actionDone: true, request: updated));
    } on Failure catch (f) {
      emit(state.copyWith(acting: false, actionFailure: f));
    }
  }

  static bool _isAccepted(ExpenseStatus status) =>
      status == ExpenseStatus.paid || status == ExpenseStatus.confirmed;

  /// Cheklarni olishda xato bo'lsa detailni yiqitmaymiz — bo'sh ro'yxat.
  Future<List<ExpenseReceipt>> _safeReceipts(int id) async {
    try {
      return await _getReceipts(id);
    } on Failure {
      return const [];
    }
  }
}
