part of 'user_detail_bloc.dart';

sealed class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Foydalanuvchi ma'lumotini yuklash / qayta yuklash.
class UserDetailRequested extends UserDetailEvent {
  const UserDetailRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
