part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class UsersRequested extends UsersEvent {
  const UsersRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class UsersLoadMore extends UsersEvent {
  const UsersLoadMore();
}

/// Qidiruv matni o'zgardi — boshqa filtrlar saqlanib, 1-sahifa qaytadan
/// yuklanadi.
class UsersSearchChanged extends UsersEvent {
  const UsersSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib,
/// 1-sahifa qaytadan yuklanadi.
class UsersFilterChanged extends UsersEvent {
  const UsersFilterChanged(this.filter);

  final UsersFilter filter;

  @override
  List<Object?> get props => [filter];
}
