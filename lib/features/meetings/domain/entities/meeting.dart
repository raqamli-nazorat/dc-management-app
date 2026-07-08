import 'package:equatable/equatable.dart';

/// Bitta yig‘ilish (`/meetings/`).
///
/// Backend kontrakti to‘liq tasdiqlanmagan (loyiha hujjatlari bilan farq
/// qilishi mumkin) — [MeetingModel.fromJson] bir nechta nomzod kalitni
/// bardoshli o‘qiydi. Bu yerda UI ko‘rsatadigan maydonlar to‘plangan.
class Meeting extends Equatable {
  const Meeting({
    required this.id,
    required this.title,
    required this.uid,
    this.projectId,
    required this.projectName,
    this.description = '',
    this.link = '',
    this.penaltyPercentage,
    required this.startDate,
    this.durationMinutes,
    required this.organizerName,
    required this.organizerRole,
    this.participantIds = const [],
    required this.participantName,
    required this.participantPosition,
    required this.isCompleted,
    required this.reason,
    required this.attended,
  });

  final int id;

  /// Yig‘ilish nomi (masalan "Dashboard redesign").
  final String title;

  /// Ko‘rsatiladigan UID (masalan "M12575") — bo‘lmasa bo‘sh.
  final String uid;

  final int? projectId;

  /// Tegishli loyiha nomi (kartada ost-yozuv).
  final String projectName;

  final String description;
  final String link;
  final String? penaltyPercentage;

  /// Boshlanish vaqti.
  final DateTime? startDate;

  final int? durationMinutes;

  /// Tashkilotchi ismi + roli (karta pastki qatori).
  final String organizerName;
  final String organizerRole;

  final List<int> participantIds;
  final String participantName;
  final String participantPosition;

  final bool isCompleted;

  /// Qatnashmaslik sababi (bo‘lsa).
  final String reason;

  /// Joriy foydalanuvchi qatnashganmi: `true` (qatnashdi) / `false`
  /// (qatnashmadi) / `null` (noma‘lum) — kartadagi nishonni tanlaydi.
  final bool? attended;

  @override
  List<Object?> get props => [
    id,
    title,
    uid,
    projectId,
    projectName,
    description,
    link,
    penaltyPercentage,
    startDate,
    durationMinutes,
    organizerName,
    organizerRole,
    participantIds,
    participantName,
    participantPosition,
    isCompleted,
    reason,
    attended,
  ];
}
