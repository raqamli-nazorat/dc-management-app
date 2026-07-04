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
    required this.projectName,
    required this.startDate,
    required this.organizerName,
    required this.organizerRole,
    required this.isCompleted,
    required this.reason,
    required this.attended,
  });

  final int id;

  /// Yig‘ilish nomi (masalan "Dashboard redesign").
  final String title;

  /// Ko‘rsatiladigan UID (masalan "M12575") — bo‘lmasa bo‘sh.
  final String uid;

  /// Tegishli loyiha nomi (kartada ost-yozuv).
  final String projectName;

  /// Boshlanish vaqti.
  final DateTime? startDate;

  /// Tashkilotchi ismi + roli (karta pastki qatori).
  final String organizerName;
  final String organizerRole;

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
        projectName,
        startDate,
        organizerName,
        organizerRole,
        isCompleted,
        reason,
        attended,
      ];
}
