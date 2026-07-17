part of 'payroll_bloc.dart';

sealed class PayrollEvent extends Equatable {
  const PayrollEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class PayrollRequested extends PayrollEvent {
  const PayrollRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class PayrollLoadMore extends PayrollEvent {
  const PayrollLoadMore();
}

/// Qidiruv matni o'zgardi — boshqa filtrlar saqlanib, 1-sahifa qaytadan
/// yuklanadi.
class PayrollSearchChanged extends PayrollEvent {
  const PayrollSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib,
/// 1-sahifa qaytadan yuklanadi.
class PayrollFilterChanged extends PayrollEvent {
  const PayrollFilterChanged(this.filter);

  final PayrollFilter filter;

  @override
  List<Object?> get props => [filter];
}
