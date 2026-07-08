import '../../../../core/usecases/usecase.dart';
import '../entities/meeting_attendance.dart';
import '../entities/meeting_attendance_update.dart';
import '../repository/meeting_repository.dart';

/// Qatnashuv yozuvini yangilash (`PATCH /meeting-attendance/{id}/`).
class UpdateMeetingAttendanceUseCase
    implements UseCase<MeetingAttendance, UpdateMeetingAttendanceParams> {
  const UpdateMeetingAttendanceUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<MeetingAttendance> call(UpdateMeetingAttendanceParams params) =>
      _repository.updateMeetingAttendance(params.id, params.update);
}

class UpdateMeetingAttendanceParams {
  const UpdateMeetingAttendanceParams({required this.id, required this.update});

  final int id;
  final MeetingAttendanceUpdate update;
}
