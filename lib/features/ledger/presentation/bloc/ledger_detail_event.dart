part of 'ledger_detail_bloc.dart';

sealed class LedgerDetailEvent extends Equatable {
  const LedgerDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Yozuvni yuklash / qayta yuklash.
class LedgerDetailRequested extends LedgerDetailEvent {
  const LedgerDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
