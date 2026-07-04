import '../../../../core/usecases/usecase.dart';
import '../entities/meeting_attendance.dart';
import '../repository/meeting_repository.dart';

/// Qatnashmaslik sababini yuborish
/// (`PATCH /meeting-attendance/{attendanceId}/`).
class SubmitAbsenceReasonUseCase
    implements UseCase<MeetingAttendance, SubmitAbsenceReasonParams> {
  const SubmitAbsenceReasonUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<MeetingAttendance> call(SubmitAbsenceReasonParams params) =>
      _repository.submitAbsenceReason(params.attendanceId, params.reason);
}

class SubmitAbsenceReasonParams {
  const SubmitAbsenceReasonParams({
    required this.attendanceId,
    required this.reason,
  });

  final int attendanceId;
  final String reason;
}
