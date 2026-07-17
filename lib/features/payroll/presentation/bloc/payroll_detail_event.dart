part of 'payroll_detail_bloc.dart';

sealed class PayrollDetailEvent extends Equatable {
  const PayrollDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Yozuvni yuklash / qayta yuklash.
class PayrollDetailRequested extends PayrollDetailEvent {
  const PayrollDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}

/// Yozuvni tasdiqlash (`POST /payroll/confirm/`).
class PayrollConfirmRequested extends PayrollDetailEvent {
  const PayrollConfirmRequested();
}
