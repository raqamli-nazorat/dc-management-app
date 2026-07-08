import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni chiqindidan tiklash (`POST /meetings/{id}/restore/`).
class RestoreMeetingUseCase implements UseCase<Meeting, int> {
  const RestoreMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(int params) => _repository.restoreMeeting(params);
}
