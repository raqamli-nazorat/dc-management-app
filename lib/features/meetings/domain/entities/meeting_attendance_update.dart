/// Partial request body for `PATCH /meeting-attendance/{id}/`.
class MeetingAttendanceUpdate {
  const MeetingAttendanceUpdate({
    this.isAttended,
    this.isExcused,
    this.absenceReason,
  });

  final bool? isAttended;
  final bool? isExcused;
  final String? absenceReason;
}
