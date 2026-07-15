import 'package:equatable/equatable.dart';

/// Loyiha bo'yicha hisobot filtri (`GET /reports/projects/` query paramlari).
///
/// Maydon → param moslashuvi:
/// - [deadlineFrom]/[deadlineTo] → `deadline_min`/`deadline_max` (Muddati)
/// - [priceFrom]/[priceTo] → `price_min`/`price_max` (Boshqaruvchi bonusi)
/// - [authorIds] → `created_by` (Muallifi — ko'p tanlov)
/// - [managerIds] → `manager` (Boshqaruvchi — ko'p tanlov)
/// - [employeeIds] → `employees` (Xodimlar — ko'p tanlov)
/// - [testerIds] → `testers` (Sinovchilar — ko'p tanlov)
/// - [search] → `search`
class ProjectReportFilter extends Equatable {
  const ProjectReportFilter({
    this.deadlineFrom,
    this.deadlineTo,
    this.priceFrom,
    this.priceTo,
    this.authorIds = const {},
    this.managerIds = const {},
    this.employeeIds = const {},
    this.testerIds = const {},
    this.search = '',
  });

  static const empty = ProjectReportFilter();

  final DateTime? deadlineFrom;
  final DateTime? deadlineTo;
  final num? priceFrom;
  final num? priceTo;
  final Set<int> authorIds;
  final Set<int> managerIds;
  final Set<int> employeeIds;
  final Set<int> testerIds;
  final String search;

  bool get hasActiveFilters =>
      deadlineFrom != null ||
      deadlineTo != null ||
      priceFrom != null ||
      priceTo != null ||
      authorIds.isNotEmpty ||
      managerIds.isNotEmpty ||
      employeeIds.isNotEmpty ||
      testerIds.isNotEmpty;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  ProjectReportFilter copyWithSearch(String search) => ProjectReportFilter(
    deadlineFrom: deadlineFrom,
    deadlineTo: deadlineTo,
    priceFrom: priceFrom,
    priceTo: priceTo,
    authorIds: authorIds,
    managerIds: managerIds,
    employeeIds: employeeIds,
    testerIds: testerIds,
    search: search,
  );

  @override
  List<Object?> get props => [
    deadlineFrom,
    deadlineTo,
    priceFrom,
    priceTo,
    authorIds,
    managerIds,
    employeeIds,
    testerIds,
    search,
  ];
}
