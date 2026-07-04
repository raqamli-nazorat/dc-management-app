import '../../../../core/usecases/usecase.dart';
import '../entities/meeting_attendance.dart';
import '../repository/meeting_repository.dart';

/// Yig‘ilishdagi qatnashuv yozuvlarini olish (`GET /meeting-attendance/?meeting=`).
class GetMeetingAttendanceUseCase
    implements UseCase<List<MeetingAttendance>, int> {
  const GetMeetingAttendanceUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<MeetingAttendance>> call(int meetingId) =>
      _repository.getMeetingAttendance(meetingId);
}
