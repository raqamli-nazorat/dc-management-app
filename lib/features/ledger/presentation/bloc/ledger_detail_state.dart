part of 'ledger_detail_bloc.dart';

enum LedgerDetailStatus { initial, loading, success, failure }

class LedgerDetailState extends Equatable {
  const LedgerDetailState({
    this.status = LedgerDetailStatus.initial,
    this.entry,
    this.failure,
  });

  final LedgerDetailStatus status;
  final LedgerEntry? entry;
  final Failure? failure;

  LedgerDetailState copyWith({
    LedgerDetailStatus? status,
    LedgerEntry? entry,
    Failure? failure,
  }) => LedgerDetailState(
    status: status ?? this.status,
    entry: entry ?? this.entry,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, entry, failure];
}
