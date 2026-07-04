import '../entities/meeting.dart';
import '../entities/meeting_attendance.dart';

/// Yig‘ilishlar domen shartnomasi. Implementatsiya `Exception`larni
/// `Failure`ga aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class MeetingRepository {
  /// Yig‘ilishlar ro‘yxati (`GET /meetings/`).
  Future<List<Meeting>> getMeetings();

  /// Bitta yig‘ilish (`GET /meetings/{id}/`).
  Future<Meeting> getMeeting(int id);

  /// Yig‘ilishdagi qatnashuv yozuvlari (`GET /meeting-attendance/?meeting=`).
  Future<List<MeetingAttendance>> getMeetingAttendance(int meetingId);

  /// Qatnashmaslik sababini yuboradi
  /// (`PATCH /meeting-attendance/{attendanceId}/`).
  Future<MeetingAttendance> submitAbsenceReason(int attendanceId, String reason);
}
