import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../entities/profile_update.dart';
import '../repository/profile_repository.dart';

/// Profilni qisman yangilash (`PATCH /users/me/`).
class UpdateMeUseCase implements UseCase<Profile, ProfileUpdate> {
  const UpdateMeUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(ProfileUpdate params) => _repository.updateMe(params);
}
