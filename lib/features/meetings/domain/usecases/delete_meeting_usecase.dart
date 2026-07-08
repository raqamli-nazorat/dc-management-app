import '../../../../core/usecases/usecase.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishni chiqindiga yuborish (`DELETE /meetings/{id}/`).
class DeleteMeetingUseCase implements UseCase<void, int> {
  const DeleteMeetingUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<void> call(int params) => _repository.deleteMeeting(params);
}
