/// Query params for `GET /meetings/`.
class MeetingFilter {
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
}
