part of 'user_reports_bloc.dart';

sealed class UserReportsEvent extends Equatable {
  const UserReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class UserReportsRequested extends UserReportsEvent {
  const UserReportsRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class UserReportsLoadMore extends UserReportsEvent {
  const UserReportsLoadMore();
}

/// Qidiruv matni o'zgardi (sarlavhadagi qidiruv paneli) — boshqa filtrlar
/// saqlanib, 1-sahifa qaytadan yuklanadi.
class UserReportsSearchChanged extends UserReportsEvent {
  const UserReportsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib, 1-sahifa
/// qaytadan yuklanadi.
class UserReportsFilterChanged extends UserReportsEvent {
  const UserReportsFilterChanged(this.filter);

  final UserReportFilter filter;

  @override
  List<Object?> get props => [filter];
}
