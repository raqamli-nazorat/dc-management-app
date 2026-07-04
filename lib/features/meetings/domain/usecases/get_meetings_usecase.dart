import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../repository/meeting_repository.dart';

/// Yig‘ilishlar ro‘yxatini olish (`GET /meetings/`).
class GetMeetingsUseCase implements UseCase<List<Meeting>, void> {
  const GetMeetingsUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<Meeting>> call(void params) => _repository.getMeetings();
}
