part of 'meeting_reason_bloc.dart';

enum MeetingReasonLoad { initial, loading, success, failure }

enum MeetingReasonSubmit { initial, loading, success, failure }

class MeetingReasonState extends Equatable {
  const MeetingReasonState({
    this.loadStatus = MeetingReasonLoad.initial,
    this.submitStatus = MeetingReasonSubmit.initial,
    this.title = '',
    this.startDate,
    this.attendanceId,
    this.myAttendance,
    this.isOrganizer = false,
    this.rows = const [],
    this.approvingId = 0,
    this.rejectedIds = const {},
    this.approveFailed = false,
    this.failure,
  });

  final MeetingReasonLoad loadStatus;
  final MeetingReasonSubmit submitStatus;

  /// Yig‘ilish sarlavhasi (header ost-yozuvi).
  final String title;
  final DateTime? startDate;

  /// Sabab yoziladigan qatnashuv yozuvi id’si (`null` — topilmadi).
  final int? attendanceId;

  /// Joriy foydalanuvchining qatnashuv yozuvi — sabab allaqachon yuborilgan
  /// bo'lsa forma o'rniga holat ko'rinishi ko'rsatiladi.
  final MeetingAttendance? myAttendance;

  /// Joriy foydalanuvchi yig‘ilish tashkilotchisi — sabab yozish o‘rniga
  /// qatnashmaganlar sabablarini tasdiqlash ro‘yxati ko‘rsatiladi.
  final bool isOrganizer;

  /// Tashkilotchi rejimi: qatnashmaganlarning attendance yozuvlari.
  final List<MeetingAttendance> rows;

  /// Hozir tasdiqlanayotgan yozuv id'si (0 — yo‘q).
  final int approvingId;

  /// Shu sessiyada rad etilgan yozuv id'lari (backend'da alohida maydon
  /// yo'q — lokal ko'rsatish uchun).
  final Set<int> rejectedIds;

  /// Oxirgi approve urinishi xato bilan tugadi (toast trigger).
  final bool approveFailed;

  final Failure? failure;

  bool get isSubmitting => submitStatus == MeetingReasonSubmit.loading;

  MeetingReasonState copyWith({
    MeetingReasonLoad? loadStatus,
    MeetingReasonSubmit? submitStatus,
    String? title,
    DateTime? startDate,
    int? attendanceId,
    MeetingAttendance? myAttendance,
    bool? isOrganizer,
    List<MeetingAttendance>? rows,
    int? approvingId,
    Set<int>? rejectedIds,
    bool? approveFailed,
    Failure? failure,
  }) => MeetingReasonState(
    loadStatus: loadStatus ?? this.loadStatus,
    submitStatus: submitStatus ?? this.submitStatus,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    attendanceId: attendanceId ?? this.attendanceId,
    myAttendance: myAttendance ?? this.myAttendance,
    isOrganizer: isOrganizer ?? this.isOrganizer,
    rows: rows ?? this.rows,
    approvingId: approvingId ?? this.approvingId,
    rejectedIds: rejectedIds ?? this.rejectedIds,
    approveFailed: approveFailed ?? false,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    submitStatus,
    title,
    startDate,
    attendanceId,
    myAttendance,
    isOrganizer,
    rows,
    approvingId,
    rejectedIds,
    approveFailed,
    failure,
  ];
}
