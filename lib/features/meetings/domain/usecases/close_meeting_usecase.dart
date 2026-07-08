import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni yopish (`POST /meetings/{id}/close/`).
class CloseMeetingUseCase implements UseCase<Meeting, int> {
  const CloseMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(int params) => _repository.closeMeeting(params);
}
