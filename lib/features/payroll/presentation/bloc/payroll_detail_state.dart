part of 'payroll_detail_bloc.dart';

enum PayrollDetailStatus { initial, loading, success, failure }

class PayrollDetailState extends Equatable {
  const PayrollDetailState({
    this.status = PayrollDetailStatus.initial,
    this.payroll,
    this.failure,
    this.confirming = false,
    this.confirmed = false,
    this.confirmFailure,
  });

  final PayrollDetailStatus status;
  final Payroll? payroll;
  final Failure? failure;

  /// Tasdiqlash so'rovi ketmoqda (tugma spinneri).
  final bool confirming;

  /// Tasdiqlash muvaffaqiyatli tugadi (bir martalik — toast + ro'yxat refresh).
  final bool confirmed;

  /// Tasdiqlash xatosi (bir martalik — toast).
  final Failure? confirmFailure;

  PayrollDetailState copyWith({
    PayrollDetailStatus? status,
    Payroll? payroll,
    Failure? failure,
    bool? confirming,
    bool? confirmed,
    Failure? confirmFailure,
  }) => PayrollDetailState(
    status: status ?? this.status,
    payroll: payroll ?? this.payroll,
    failure: failure,
    confirming: confirming ?? this.confirming,
    confirmed: confirmed ?? this.confirmed,
    confirmFailure: confirmFailure,
  );

  @override
  List<Object?> get props => [
    status,
    payroll,
    failure,
    confirming,
    confirmed,
    confirmFailure,
  ];
}
