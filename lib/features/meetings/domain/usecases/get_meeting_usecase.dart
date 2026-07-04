import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repository/meeting_repository.dart';

/// Bitta yig‘ilishni olish (`GET /meetings/{id}/`).
class GetMeetingUseCase implements UseCase<Meeting, int> {
  const GetMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(int id) => _repository.getMeeting(id);
}
