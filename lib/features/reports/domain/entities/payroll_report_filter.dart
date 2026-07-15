import 'package:equatable/equatable.dart';

/// Ish haqi hisoboti filtri (`GET /reports/payrolls/` query paramlari).
/// [month] — 1..12 (backend `month_year` `YYYY-MM` kutadi, yil sifatida joriy
/// yil olinadi — dizaynda faqat oy tanlanadi). [isConfirmed] — Holati:
/// `false` Hisoblangan, `true` Tasdiqlangan.
class PayrollReportFilter extends Equatable {
  const PayrollReportFilter({
    this.search = '',
    this.createdFrom,
    this.createdTo,
    this.confirmedFrom,
    this.confirmedTo,
    this.userIds = const {},
    this.accountantIds = const {},
    this.month,
    this.isConfirmed,
    this.totalFrom,
    this.totalTo,
    this.salaryFrom,
    this.salaryTo,
    this.kpiFrom,
    this.kpiTo,
    this.penaltyFrom,
    this.penaltyTo,
  });

  static const empty = PayrollReportFilter();

  final String search;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final DateTime? confirmedFrom;
  final DateTime? confirmedTo;
  final Set<int> userIds;
  final Set<int> accountantIds;
  final int? month;
  final bool? isConfirmed;
  final num? totalFrom;
  final num? totalTo;
  final num? salaryFrom;
  final num? salaryTo;
  final num? kpiFrom;
  final num? kpiTo;
  final num? penaltyFrom;
  final num? penaltyTo;

  bool get hasActiveFilters =>
      createdFrom != null ||
      createdTo != null ||
      confirmedFrom != null ||
      confirmedTo != null ||
      userIds.isNotEmpty ||
      accountantIds.isNotEmpty ||
      month != null ||
      isConfirmed != null ||
      totalFrom != null ||
      totalTo != null ||
      salaryFrom != null ||
      salaryTo != null ||
      kpiFrom != null ||
      kpiTo != null ||
      penaltyFrom != null ||
      penaltyTo != null;

  PayrollReportFilter copyWithSearch(String search) => PayrollReportFilter(
    search: search,
    createdFrom: createdFrom,
    createdTo: createdTo,
    confirmedFrom: confirmedFrom,
    confirmedTo: confirmedTo,
    userIds: userIds,
    accountantIds: accountantIds,
    month: month,
    isConfirmed: isConfirmed,
    totalFrom: totalFrom,
    totalTo: totalTo,
    salaryFrom: salaryFrom,
    salaryTo: salaryTo,
    kpiFrom: kpiFrom,
    kpiTo: kpiTo,
    penaltyFrom: penaltyFrom,
    penaltyTo: penaltyTo,
  );

  @override
  List<Object?> get props => [
    search,
    createdFrom,
    createdTo,
    confirmedFrom,
    confirmedTo,
    userIds,
    accountantIds,
    month,
    isConfirmed,
    totalFrom,
    totalTo,
    salaryFrom,
    salaryTo,
    kpiFrom,
    kpiTo,
    penaltyFrom,
    penaltyTo,
  ];
}
