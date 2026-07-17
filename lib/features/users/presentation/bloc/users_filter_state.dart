part of 'users_filter_bloc.dart';

class UsersFilterState extends Equatable {
  const UsersFilterState({this.loading = false, this.positions = const []});

  final bool loading;
  final List<Position> positions;

  UsersFilterState copyWith({bool? loading, List<Position>? positions}) =>
      UsersFilterState(
        loading: loading ?? this.loading,
        positions: positions ?? this.positions,
      );

  @override
  List<Object?> get props => [loading, positions];
}
