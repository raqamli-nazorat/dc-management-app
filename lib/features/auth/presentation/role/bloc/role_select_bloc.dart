import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../profile/domain/usecases/update_me_usecase.dart';

part 'role_select_event.dart';
part 'role_select_state.dart';

/// Rol tanlash bloci — tanlangan faol rolni backendga yozadi
/// (`PATCH /users/me/` → `{active_role}`). Muvaffaqiyat/xato holatini
/// boshqaradi; lokal sessiya (`SessionRoleSelected`) faqat backend
/// tasdiqlangandan keyin yangilanadi (sahifa listener'ida).
class RoleSelectBloc extends Bloc<RoleSelectEvent, RoleSelectState> {
  RoleSelectBloc({required UpdateMeUseCase updateMe})
      : _updateMe = updateMe,
        super(const RoleSelectState()) {
    on<RoleSelectSubmitted>(_onSubmitted);
  }

  final UpdateMeUseCase _updateMe;

  Future<void> _onSubmitted(
    RoleSelectSubmitted event,
    Emitter<RoleSelectState> emit,
  ) async {
    emit(RoleSelectState(
      status: RoleSelectStatus.loading,
      submittingRole: event.role,
    ));
    try {
      await _updateMe({'active_role': event.role});
      emit(RoleSelectState(
        status: RoleSelectStatus.success,
        submittingRole: event.role,
      ));
    } on Failure catch (f) {
      emit(RoleSelectState(
        status: RoleSelectStatus.failure,
        submittingRole: event.role,
        failure: f,
      ));
    }
  }
}
