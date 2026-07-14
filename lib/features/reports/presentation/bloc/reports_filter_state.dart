part of 'reports_filter_bloc.dart';

class ReportsFilterState extends Equatable {
  const ReportsFilterState({
    this.loading = false,
    this.positions = const [],
    this.users = const [],
    this.regions = const [],
  });

  final bool loading;
  final List<Position> positions;
  final List<UserShort> users;
  final List<Region> regions;

  ReportsFilterState copyWith({
    bool? loading,
    List<Position>? positions,
    List<UserShort>? users,
    List<Region>? regions,
  }) => ReportsFilterState(
    loading: loading ?? this.loading,
    positions: positions ?? this.positions,
    users: users ?? this.users,
    regions: regions ?? this.regions,
  );

  @override
  List<Object?> get props => [loading, positions, users, regions];
}
