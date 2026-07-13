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
    this.failure,
  });

  final MeetingReasonLoad loadStatus;
  final MeetingReasonSubmit submitStatus;

  /// Yig‘ilish sarlavhasi (header ost-yozuvi).
  final String title;
  final DateTime? startDate;

  /// Sabab yoziladigan qatnashuv yozuvi id’si (`null` — topilmadi).
  final int? attendanceId;

  final Failure? failure;

  bool get isSubmitting => submitStatus == MeetingReasonSubmit.loading;

  MeetingReasonState copyWith({
    MeetingReasonLoad? loadStatus,
    MeetingReasonSubmit? submitStatus,
    String? title,
    DateTime? startDate,
    int? attendanceId,
    Failure? failure,
  }) => MeetingReasonState(
    loadStatus: loadStatus ?? this.loadStatus,
    submitStatus: submitStatus ?? this.submitStatus,
    title: title ?? this.title,
    startDate: startDate ?? this.startDate,
    attendanceId: attendanceId ?? this.attendanceId,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    loadStatus,
    submitStatus,
    title,
    startDate,
    attendanceId,
    failure,
  ];
}
