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
    this.isOrganizer = false,
    this.rows = const [],
    this.approvingId = 0,
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

  /// Joriy foydalanuvchi yig‘ilish tashkilotchisi — sabab yozish o‘rniga
  /// qatnashmaganlar sabablarini tasdiqlash ro‘yxati ko‘rsatiladi.
  final bool isOrganizer;

  /// Tashkilotchi rejimi: qatnashmaganlarning attendance yozuvlari.
  final List<MeetingAttendance> rows;

  /// Hozir tasdiqlanayotgan yozuv id'si (0 — yo‘q).
  final int approvingId;

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
    bool? isOrganizer,
    List<MeetingAttendance>? rows,
    int? approvingId,
    bool? approveFailed,
    Failure? failure,
  }) => MeetingReasonState(
    loadStatus: loadStatus ?? this.loadStatus,
    submitStatus: submitStatus ?? this.submitStatus,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    attendanceId: attendanceId ?? this.attendanceId,
    isOrganizer: isOrganizer ?? this.isOrganizer,
    rows: rows ?? this.rows,
    approvingId: approvingId ?? this.approvingId,
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
    isOrganizer,
    rows,
    approvingId,
    approveFailed,
    failure,
  ];
}
