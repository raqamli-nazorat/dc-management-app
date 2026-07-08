import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repository/meeting_repository.dart';

/// Chiqindidagi yig'ilishlar (`GET /meetings/trash/`).
class GetTrashedMeetingsUseCase implements UseCase<List<Meeting>, void> {
  const GetTrashedMeetingsUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<Meeting>> call(void params) => _repository.getTrashedMeetings();
}
