import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../entities/meeting_form.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni to'liq yangilash (`PUT /meetings/{id}/`).
class UpdateMeetingUseCase implements UseCase<Meeting, UpdateMeetingParams> {
  const UpdateMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<Meeting> call(UpdateMeetingParams params) =>
      _repository.updateMeeting(params.id, params.form);
}

class UpdateMeetingParams {
  const UpdateMeetingParams({required this.id, required this.form});

  final int id;
  final MeetingForm form;
}
