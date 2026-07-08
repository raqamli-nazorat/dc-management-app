import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../entities/meeting_form.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni qisman yangilash (`PATCH /meetings/{id}/`).
class PatchMeetingUseCase implements UseCase<Meeting, PatchMeetingParams> {
  const PatchMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(PatchMeetingParams params) =>
      _repository.patchMeeting(params.id, params.patch);
}

class PatchMeetingParams {
  const PatchMeetingParams({required this.id, required this.patch});

  final int id;
  final MeetingPatch patch;
}
