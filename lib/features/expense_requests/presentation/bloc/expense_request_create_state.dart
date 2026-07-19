part of 'expense_request_create_bloc.dart';

enum ExpenseRequestCreateStatus { initial, submitting, success, failure }

class ExpenseRequestCreateState extends Equatable {
  const ExpenseRequestCreateState({
    this.status = ExpenseRequestCreateStatus.initial,
    this.created,
    this.failure,
  });

  final ExpenseRequestCreateStatus status;
  final ExpenseRequest? created;
  final Failure? failure;

  ExpenseRequestCreateState copyWith({
    ExpenseRequestCreateStatus? status,
    ExpenseRequest? created,
    Failure? failure,
  }) => ExpenseRequestCreateState(
    status: status ?? this.status,
    created: created ?? this.created,
    failure: failure ?? this.failure,
  );

  @override
  List<Object?> get props => [status, created, failure];
}
