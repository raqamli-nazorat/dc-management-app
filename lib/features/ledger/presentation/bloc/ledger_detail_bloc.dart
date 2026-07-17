import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/usecases/get_ledger_detail_usecase.dart';

part 'ledger_detail_event.dart';
part 'ledger_detail_state.dart';

/// Moliya tarixi detail sahifasi bloci (`GET /ledger/{id}/`).
class LedgerDetailBloc extends Bloc<LedgerDetailEvent, LedgerDetailState> {
  LedgerDetailBloc({required GetLedgerDetailUseCase getEntry})
    : _getEntry = getEntry,
      super(const LedgerDetailState()) {
    on<LedgerDetailRequested>(_onRequested);
  }

  final GetLedgerDetailUseCase _getEntry;

  Future<void> _onRequested(
    LedgerDetailRequested event,
    Emitter<LedgerDetailState> emit,
  ) async {
    emit(state.copyWith(status: LedgerDetailStatus.loading));
    try {
      final entry = await _getEntry(event.id);
      emit(state.copyWith(status: LedgerDetailStatus.success, entry: entry));
    } on Failure catch (f) {
      emit(state.copyWith(status: LedgerDetailStatus.failure, failure: f));
    }
  }
}
