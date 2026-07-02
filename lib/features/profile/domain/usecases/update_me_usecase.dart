import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repository/profile_repository.dart';

/// Profilni qisman yangilash (`PATCH /users/me/`).
class UpdateMeUseCase implements UseCase<Profile, Map<String, dynamic>> {
  const UpdateMeUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(Map<String, dynamic> params) =>
      _repository.updateMe(params);
}
