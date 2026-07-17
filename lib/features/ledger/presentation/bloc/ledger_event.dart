part of 'ledger_bloc.dart';

sealed class LedgerEvent extends Equatable {
  const LedgerEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class LedgerRequested extends LedgerEvent {
  const LedgerRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class LedgerLoadMore extends LedgerEvent {
  const LedgerLoadMore();
}

/// Qidiruv matni o'zgardi — boshqa filtrlar saqlanib, 1-sahifa qaytadan
/// yuklanadi.
class LedgerSearchChanged extends LedgerEvent {
  const LedgerSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib,
/// 1-sahifa qaytadan yuklanadi.
class LedgerFilterChanged extends LedgerEvent {
  const LedgerFilterChanged(this.filter);

  final LedgerFilter filter;

  @override
  List<Object?> get props => [filter];
}
