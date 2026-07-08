import 'package:equatable/equatable.dart';

/// Query params for `GET /meetings/`.
class MeetingFilter extends Equatable {
  const MeetingFilter({
    this.isCompleted,
    this.ordering,
    this.organizerId,
    this.page,
    this.projectId,
    this.search,
    this.startDateGte,
    this.startDateLte,
  });

  static const empty = MeetingFilter();

  final bool? isCompleted;
  final String? ordering;
  final int? organizerId;
  final int? page;
  final int? projectId;
  final String? search;
  final DateTime? startDateGte;
  final DateTime? startDateLte;

  MeetingFilter copyWithSearch(String search) => MeetingFilter(
    isCompleted: isCompleted,
    ordering: ordering,
    organizerId: organizerId,
    page: page,
    projectId: projectId,
    search: search,
    startDateGte: startDateGte,
    startDateLte: startDateLte,
  );

  @override
  List<Object?> get props => [
    isCompleted,
    ordering,
    organizerId,
    page,
    projectId,
    search,
    startDateGte,
    startDateLte,
  ];
}
