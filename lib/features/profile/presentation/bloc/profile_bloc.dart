import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_me_usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// Profil holati bloci — hozircha faqat `GET /users/me/`ni boshqaradi.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required GetMeUseCase getMe})
      : _getMe = getMe,
        super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
  }

  final GetMeUseCase _getMe;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _getMe(null);
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } on Failure catch (f) {
      emit(state.copyWith(status: ProfileStatus.failure, failure: f));
    }
  }
}
