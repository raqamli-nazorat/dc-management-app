import '../../../../core/usecases/usecase.dart';
import '../entities/profile.dart';
import '../repository/profile_repository.dart';

/// Joriy foydalanuvchi profilini olish.
class GetMeUseCase implements UseCase<Profile, void> {
  const GetMeUseCase(this._repository);

  final ProfileRepository _repository;

  @override
  Future<Profile> call(void params) => _repository.getMe();
}
