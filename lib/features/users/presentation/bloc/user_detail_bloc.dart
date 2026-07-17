import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/usecases/get_app_user_detail_usecase.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

/// Foydalanuvchi detail sahifasi bloci (`GET /users/{id}/`).
class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  UserDetailBloc({required GetAppUserDetailUseCase getUser})
    : _getUser = getUser,
      super(const UserDetailState()) {
    on<UserDetailRequested>(_onRequested);
  }

  final GetAppUserDetailUseCase _getUser;

  Future<void> _onRequested(
    UserDetailRequested event,
    Emitter<UserDetailState> emit,
  ) async {
    emit(state.copyWith(status: UserDetailStatus.loading));
    try {
      final user = await _getUser(event.id);
      emit(state.copyWith(status: UserDetailStatus.success, user: user));
    } on Failure catch (f) {
      emit(state.copyWith(status: UserDetailStatus.failure, failure: f));
    }
  }
}
