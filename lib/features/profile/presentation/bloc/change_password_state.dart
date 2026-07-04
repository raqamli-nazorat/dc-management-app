part of 'change_password_bloc.dart';

enum ChangePasswordStatus { initial, loading, success, failure }

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.status = ChangePasswordStatus.initial,
    this.failure,
  });

  final ChangePasswordStatus status;
  final Failure? failure;

  bool get isLoading => status == ChangePasswordStatus.loading;

  @override
  List<Object?> get props => [status, failure];
}
