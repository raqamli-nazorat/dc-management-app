import 'package:equatable/equatable.dart';

/// Foydalanuvchining bitta yig‘ilishdagi qatnashuv yozuvi
/// (`/meeting-attendance/`). Qatnashmaslik sababi shu yozuvga yoziladi.
class MeetingAttendance extends Equatable {
  const MeetingAttendance({
    required this.id,
    required this.meetingId,
    required this.meetingTitle,
    required this.isAttended,
    required this.isExcused,
    required this.absenceReason,
    required this.userId,
    this.userName = '',
    this.userPosition = '',
    this.userAvatar = '',
  });

  final int id;
  final int? meetingId;
  final String meetingTitle;
  final bool isAttended;
  final bool isExcused;
  final String absenceReason;

  /// Qatnashuvchi (user_info.id) — o‘z yozuvimni ajratishda ishlatiladi.
  final int? userId;

  /// Qatnashuvchi ma'lumotlari (`user_info`) — tashkilotchining sabab
  /// tasdiqlash ro'yxatida ko'rsatiladi.
  final String userName;
  final String userPosition;
  final String userAvatar;

  @override
  List<Object?> get props => [
    id,
    meetingId,
    meetingTitle,
    isAttended,
    isExcused,
    absenceReason,
    userId,
    userName,
    userPosition,
    userAvatar,
  ];
}
