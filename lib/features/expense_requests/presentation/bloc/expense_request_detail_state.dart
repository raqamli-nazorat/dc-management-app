part of 'expense_request_detail_bloc.dart';

enum ExpenseRequestDetailStatus { initial, loading, success, failure }

class ExpenseRequestDetailState extends Equatable {
  const ExpenseRequestDetailState({
    this.status = ExpenseRequestDetailStatus.initial,
    this.request,
    this.failure,
    this.acting = false,
    this.actionDone = false,
    this.actionFailure,
  });

  final ExpenseRequestDetailStatus status;
  final ExpenseRequest? request;
  final Failure? failure;

  /// To'lov/rad etish so'rovi ketmoqda — tugmalar bloklanadi.
  final bool acting;

  /// Amal muvaffaqiyatli yakunlandi — sahifa `pop(true)` qiladi.
  final bool actionDone;

  /// Amal xatosi (backend xabari toast orqali ko'rsatiladi).
  final Failure? actionFailure;

  ExpenseRequestDetailState copyWith({
    ExpenseRequestDetailStatus? status,
    ExpenseRequest? request,
    Failure? failure,
    bool? acting,
    bool? actionDone,
    Failure? actionFailure,
  }) => ExpenseRequestDetailState(
    status: status ?? this.status,
    request: request ?? this.request,
    failure: failure ?? this.failure,
    acting: acting ?? this.acting,
    actionDone: actionDone ?? this.actionDone,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    request,
    failure,
    acting,
    actionDone,
    actionFailure,
  ];
}
