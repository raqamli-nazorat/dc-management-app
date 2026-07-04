import '../../domain/entities/meeting_attendance.dart';

/// [MeetingAttendance] JSON serializatsiyasi (`/meeting-attendance/`).
class MeetingAttendanceModel extends MeetingAttendance {
  const MeetingAttendanceModel({
    required super.id,
    required super.meetingId,
    required super.meetingTitle,
    required super.isAttended,
    required super.isExcused,
    required super.absenceReason,
    required super.userId,
  });

  factory MeetingAttendanceModel.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'];
    final userId = userInfo is Map
        ? (userInfo['id'] as num?)?.toInt()
        : (json['user'] as num?)?.toInt();

    return MeetingAttendanceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      meetingId: (json['meeting'] as num?)?.toInt(),
      meetingTitle: json['meeting_title']?.toString() ?? '',
      isAttended: (json['is_attended'] as bool?) ?? false,
      isExcused: (json['is_excused'] as bool?) ?? false,
      absenceReason: json['absence_reason']?.toString() ?? '',
      userId: userId,
    );
  }
}
