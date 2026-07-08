/// Query params for `GET /meeting-attendance/`.
class MeetingAttendanceFilter {
  const MeetingAttendanceFilter({
    this.isAttended,
    this.meetingId,
    this.page,
    this.userId,
  });

  static const empty = MeetingAttendanceFilter();

  final bool? isAttended;
  final int? meetingId;
  final int? page;
  final int? userId;
}
