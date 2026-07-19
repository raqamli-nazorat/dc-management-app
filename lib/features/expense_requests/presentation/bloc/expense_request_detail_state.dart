part of 'expense_request_detail_bloc.dart';

enum ExpenseRequestDetailStatus { initial, loading, success, failure }

enum ExpenseRequestAction { none, pay, cancel, confirm }

class ExpenseRequestDetailState extends Equatable {
  const ExpenseRequestDetailState({
    this.status = ExpenseRequestDetailStatus.initial,
    this.request,
    this.receipts = const [],
    this.failure,
    this.acting = false,
    this.actionDone = false,
    this.action = ExpenseRequestAction.none,
    this.actionFailure,
  });

  final ExpenseRequestDetailStatus status;
  final ExpenseRequest? request;

  /// Qabul qilingan so'rov cheklari (faqat paid/confirmed holatda yuklanadi).
  final List<ExpenseReceipt> receipts;

  final Failure? failure;

  /// To'lov/rad etish so'rovi ketmoqda — tugmalar bloklanadi.
  final bool acting;

  /// Amal muvaffaqiyatli yakunlandi — sahifa `pop(true)` qiladi.
  final bool actionDone;


  /// Muvaffaqiyatli yakunlangan amal turi ? toast matnini statusdan ajratadi.
  final ExpenseRequestAction action;
  /// Amal xatosi (backend xabari toast orqali ko'rsatiladi).
  final Failure? actionFailure;

  ExpenseRequestDetailState copyWith({
    ExpenseRequestDetailStatus? status,
    ExpenseRequest? request,
    List<ExpenseReceipt>? receipts,
    ExpenseRequestAction? action,
    Failure? failure,
    bool? acting,
    bool? actionDone,
    Failure? actionFailure,
  }) => ExpenseRequestDetailState(
    status: status ?? this.status,
    request: request ?? this.request,
    receipts: receipts ?? this.receipts,
    action: action ?? this.action,
    failure: failure ?? this.failure,
    acting: acting ?? this.acting,
    actionDone: actionDone ?? this.actionDone,
    actionFailure: actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    request,
    receipts,
    action,
    failure,
    acting,
    actionDone,
    actionFailure,
  ];
}
