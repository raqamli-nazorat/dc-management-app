import '../../../../core/usecases/usecase.dart';
import '../entities/meeting_attendance.dart';
import '../repository/meeting_repository.dart';

/// Bitta qatnashuv yozuvi (`GET /meeting-attendance/{id}/`).
class GetMeetingAttendanceByIdUseCase
    implements UseCase<MeetingAttendance, int> {
  const GetMeetingAttendanceByIdUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<MeetingAttendance> call(int params) =>
      _repository.getMeetingAttendanceById(params);
}
