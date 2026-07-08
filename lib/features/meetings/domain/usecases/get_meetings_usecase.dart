import '../../../../core/usecases/usecase.dart';
import '../entities/meeting.dart';
import '../entities/meeting_filter.dart';
import '../repository/meeting_repository.dart';

/// Yig'ilishlar ro'yxatini olish (`GET /meetings/`).
class GetMeetingsUseCase implements UseCase<List<Meeting>, MeetingFilter?> {
  const GetMeetingsUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<Meeting>> call(MeetingFilter? params) =>
      _repository.getMeetings(filter: params ?? MeetingFilter.empty);
}
