part of 'role_select_bloc.dart';

enum RoleSelectStatus { initial, loading, success, failure }

class RoleSelectState extends Equatable {
  const RoleSelectState({
    this.status = RoleSelectStatus.initial,
    this.submittingRole,
    this.failure,
  });

  final RoleSelectStatus status;

  /// Hozir backendga yozilayotgan/urinilgan rol — tegishli kartada spinner
  /// ko‘rsatish uchun.
  final String? submittingRole;

  final Failure? failure;

  bool get isLoading => status == RoleSelectStatus.loading;

  @override
  List<Object?> get props => [status, submittingRole, failure];
}
