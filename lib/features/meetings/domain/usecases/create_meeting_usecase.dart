import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../entities/meeting_form.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilish yaratish (`POST /meetings/`).
class CreateMeetingUseCase implements UseCase<Meeting, MeetingForm> {
  const CreateMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(MeetingForm params) => _repository.createMeeting(params);
}
