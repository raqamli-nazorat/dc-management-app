part of 'user_detail_bloc.dart';

enum UserDetailStatus { initial, loading, success, failure }

class UserDetailState extends Equatable {
  const UserDetailState({
    this.status = UserDetailStatus.initial,
    this.user,
    this.failure,
  });

  final UserDetailStatus status;
  final AppUser? user;
  final Failure? failure;

  UserDetailState copyWith({
    UserDetailStatus? status,
    AppUser? user,
    Failure? failure,
  }) => UserDetailState(
    status: status ?? this.status,
    user: user ?? this.user,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, user, failure];
}
