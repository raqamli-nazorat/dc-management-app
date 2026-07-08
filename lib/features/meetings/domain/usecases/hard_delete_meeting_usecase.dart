import '../../../../core/usecases/usecase.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni butunlay o'chirish (`DELETE /meetings/{id}/hard_delete/`).
class HardDeleteMeetingUseCase implements UseCase<void, int> {
  const HardDeleteMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<void> call(int params) => _repository.hardDeleteMeeting(params);
}
