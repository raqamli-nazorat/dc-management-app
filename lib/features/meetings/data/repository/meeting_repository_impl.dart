import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/entities/meeting_attendance_filter.dart';
import '../../domain/entities/meeting_attendance_update.dart';
import '../../domain/entities/meeting_filter.dart';
import '../../domain/entities/meeting_form.dart';
import '../../domain/repository/meeting_repository.dart';
import '../data_sources/meeting_remote_data_source.dart';

/// [MeetingRepository] implementatsiyasi - data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class MeetingRepositoryImpl implements MeetingRepository {
  const MeetingRepositoryImpl(this._remote);

  final MeetingRemoteDataSource _remote;

  @override
  Future<List<Meeting>> getMeetings({
    MeetingFilter filter = MeetingFilter.empty,
  }) => _guard(() => _remote.getMeetings(filter: filter));

  @override
  Future<Meeting> createMeeting(MeetingForm form) =>
      _guard(() => _remote.createMeeting(form));

  @override
  Future<Meeting> getMeeting(int id) => _guard(() => _remote.getMeeting(id));

  @override
  Future<Meeting> updateMeeting(int id, MeetingForm form) =>
      _guard(() => _remote.updateMeeting(id, form));

  @override
  Future<Meeting> patchMeeting(int id, MeetingPatch patch) =>
      _guard(() => _remote.patchMeeting(id, patch));

  @override
  Future<void> deleteMeeting(int id) => _guard(() => _remote.deleteMeeting(id));

  @override
  Future<Meeting> closeMeeting(int id) =>
      _guard(() => _remote.closeMeeting(id));

  @override
  Future<List<Meeting>> getTrashedMeetings() =>
      _guard(_remote.getTrashedMeetings);

  @override
  Future<void> hardDeleteMeeting(int id) =>
      _guard(() => _remote.hardDeleteMeeting(id));

  @override
  Future<Meeting> restoreMeeting(int id) =>
      _guard(() => _remote.restoreMeeting(id));

  @override
  Future<List<MeetingAttendance>> getMeetingAttendance(int meetingId) =>
      _guard(() => _remote.getMeetingAttendance(meetingId));

  @override
  Future<List<MeetingAttendance>> listMeetingAttendance({
    MeetingAttendanceFilter filter = MeetingAttendanceFilter.empty,
  }) => _guard(() => _remote.listMeetingAttendance(filter: filter));

  @override
  Future<MeetingAttendance> getMeetingAttendanceById(int id) =>
      _guard(() => _remote.getMeetingAttendanceById(id));

  @override
  Future<MeetingAttendance> updateMeetingAttendance(
    int attendanceId,
    MeetingAttendanceUpdate update,
  ) => _guard(() => _remote.updateMeetingAttendance(attendanceId, update));

  @override
  Future<MeetingAttendance> submitAbsenceReason(
    int attendanceId,
    String reason,
  ) => _guard(() => _remote.submitAbsenceReason(attendanceId, reason));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
