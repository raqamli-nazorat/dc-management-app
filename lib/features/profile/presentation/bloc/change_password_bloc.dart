import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/storage_service.dart';
import '../../domain/usecases/change_password_usecase.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

/// Parolni almashtirish bloci — eski parol + yangi parolni backendga yozadi
/// (`PUT /users/me/change-password/`). Muvaffaqiyat/xato holatini boshqaradi;
/// dialog listener'i muvaffaqiyatda o'zini yopib, toast ko'rsatadi.
class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  ChangePasswordBloc({
    required ChangePasswordUseCase changePassword,
    required StorageService storage,
  })  : _changePassword = changePassword,
        _storage = storage,
        super(const ChangePasswordState()) {
    on<ChangePasswordSubmitted>(_onSubmitted);
  }

  final ChangePasswordUseCase _changePassword;
  final StorageService _storage;

  Future<void> _onSubmitted(
    ChangePasswordSubmitted event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(const ChangePasswordState(status: ChangePasswordStatus.loading));
    try {
      await _changePassword(
        ChangePasswordParams(
          oldPassword: event.oldPassword,
          newPassword: event.newPassword,
          confirmNewPassword: event.confirmNewPassword,
        ),
      );
      // Parol = PIN. Yangi parol uzunligini saqlaymiz — aks holda PIN ekrani
      // eski (o'zgargan) parol uzunligicha slot ko'rsatib qolaveradi.
      await _storage.setString(
        StorageKeys.pinLength,
        event.newPassword.length.toString(),
      );
      emit(const ChangePasswordState(status: ChangePasswordStatus.success));
    } on Failure catch (f) {
      emit(ChangePasswordState(
        status: ChangePasswordStatus.failure,
        failure: f,
      ));
    }
  }
}
