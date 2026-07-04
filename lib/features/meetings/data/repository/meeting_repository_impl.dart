import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_attendance.dart';
import '../../domain/repository/meeting_repository.dart';
import '../data_sources/meeting_remote_data_source.dart';

/// [MeetingRepository] implementatsiyasi — data source `Exception`larini
/// domen `Failure`lariga aylantiradi.
class MeetingRepositoryImpl implements MeetingRepository {
  const MeetingRepositoryImpl(this._remote);

  final MeetingRemoteDataSource _remote;

  @override
  Future<List<Meeting>> getMeetings() => _guard(() => _remote.getMeetings());

  @override
  Future<Meeting> getMeeting(int id) => _guard(() => _remote.getMeeting(id));

  @override
  Future<List<MeetingAttendance>> getMeetingAttendance(int meetingId) =>
      _guard(() => _remote.getMeetingAttendance(meetingId));

  @override
  Future<MeetingAttendance> submitAbsenceReason(
    int attendanceId,
    String reason,
  ) =>
      _guard(() => _remote.submitAbsenceReason(attendanceId, reason));

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
