import '../entities/meeting.dart';
import '../entities/meeting_attendance.dart';
import '../entities/meeting_attendance_filter.dart';
import '../entities/meeting_attendance_update.dart';
import '../entities/meeting_filter.dart';
import '../entities/meeting_form.dart';

/// Yig'ilishlar domen shartnomasi. Implementatsiya `Exception`larni
/// `Failure`ga aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class MeetingRepository {
  /// Yig'ilishlar ro'yxati (`GET /meetings/`).
  Future<List<Meeting>> getMeetings({
    MeetingFilter filter = MeetingFilter.empty,
  });

  /// Yig'ilish yaratish (`POST /meetings/`).
  Future<Meeting> createMeeting(MeetingForm form);

  /// Bitta yig'ilish (`GET /meetings/{id}/`).
  Future<Meeting> getMeeting(int id);

  /// Yig'ilishni to'liq yangilash (`PUT /meetings/{id}/`).
  Future<Meeting> updateMeeting(int id, MeetingForm form);

  /// Yig'ilishni qisman yangilash (`PATCH /meetings/{id}/`).
  Future<Meeting> patchMeeting(int id, MeetingPatch patch);

  /// Yig'ilishni chiqindiga yuborish (`DELETE /meetings/{id}/`).
  Future<void> deleteMeeting(int id);

  /// Yig'ilishni yopish (`POST /meetings/{id}/close/`).
  Future<Meeting> closeMeeting(int id);

  /// Chiqindidagi yig'ilishlar (`GET /meetings/trash/`).
  Future<List<Meeting>> getTrashedMeetings();

  /// Yig'ilishni butunlay o'chirish (`DELETE /meetings/{id}/hard_delete/`).
  Future<void> hardDeleteMeeting(int id);

  /// Yig'ilishni chiqindidan tiklash (`POST /meetings/{id}/restore/`).
  Future<Meeting> restoreMeeting(int id);

  /// Yig'ilishdagi qatnashuv yozuvlari (`GET /meeting-attendance/?meeting=`).
  Future<List<MeetingAttendance>> getMeetingAttendance(int meetingId);

  /// Qatnashuv yozuvlari ro'yxati (`GET /meeting-attendance/`).
  Future<List<MeetingAttendance>> listMeetingAttendance({
    MeetingAttendanceFilter filter = MeetingAttendanceFilter.empty,
  });

  /// Bitta qatnashuv yozuvi (`GET /meeting-attendance/{id}/`).
  Future<MeetingAttendance> getMeetingAttendanceById(int id);

  /// Qatnashuv yozuvini yangilash (`PATCH /meeting-attendance/{id}/`).
  Future<MeetingAttendance> updateMeetingAttendance(
    int attendanceId,
    MeetingAttendanceUpdate update,
  );

  /// Qatnashmaslik sababini yuboradi
  /// (`PATCH /meeting-attendance/{attendanceId}/`).
  Future<MeetingAttendance> submitAbsenceReason(
    int attendanceId,
    String reason,
  );
}
