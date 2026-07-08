import '../../../../core/usecases/usecase.dart';
import '../entities/meeting_attendance.dart';
import '../entities/meeting_attendance_filter.dart';
import '../repository/meeting_repository.dart';

/// Qatnashuv yozuvlari ro'yxati (`GET /meeting-attendance/`).
class ListMeetingAttendanceUseCase
    implements UseCase<List<MeetingAttendance>, MeetingAttendanceFilter?> {
  const ListMeetingAttendanceUseCase(this._repository);

  final MeetingRepository _repository;

  @override
  Future<List<MeetingAttendance>> call(MeetingAttendanceFilter? params) =>
      _repository.listMeetingAttendance(
        filter: params ?? MeetingAttendanceFilter.empty,
      );
}
