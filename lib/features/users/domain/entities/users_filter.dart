import 'package:equatable/equatable.dart';

/// Ro'yxatni tartiblash varianti → `ordering` query parami.
///
/// Sxema `ordering` maydonlarini sanab bermaydi (DRF `OrderingFilter`) —
/// `username`/`date_joined` deb faraz qilinadi; noto'g'ri maydonni DRF
/// jimgina e'tiborsiz qoldiradi.
enum UsersOrdering {
  nameAsc('username'),
  nameDesc('-username'),
  newestFirst('-date_joined'),
  oldestFirst('date_joined');

  const UsersOrdering(this.apiValue);

  final String apiValue;
}

/// Foydalanuvchilar ro'yxati filtri (`GET /users/` query paramlari).
///
/// Maydon → param moslashuvi:
/// - [positionId] → `position` (lavozim FK)
/// - [role] → `roles` (xom rol kaliti, masalan `admin`)
/// - [ordering] → `ordering`
/// - [search] → `search`
class UsersFilter extends Equatable {
  const UsersFilter({
    this.positionId,
    this.role,
    this.ordering,
    this.search = '',
  });

  static const empty = UsersFilter();

  final int? positionId;
  final String? role;
  final UsersOrdering? ordering;
  final String search;

  bool get hasActiveFilters =>
      positionId != null || role != null || ordering != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  UsersFilter copyWithSearch(String search) => UsersFilter(
    positionId: positionId,
    role: role,
    ordering: ordering,
    search: search,
  );

  @override
  List<Object?> get props => [positionId, role, ordering, search];
}
