import 'package:equatable/equatable.dart';

/// Ish haqi filtri (`GET /payroll/` query paramlari).
///
/// Maydon → param moslashuvi:
/// - [month] → `month` (Oy — aniq oy, `YYYY-MM-01`)
/// - [createdFrom]/[createdTo] → `month__gte`/`month__lte` (Sana oralig'i —
///   payroll'da alohida `created_at` filtri yo'q, shu bois oy oralig'iga
///   bog'lanadi)
/// - [totalFrom]/[totalTo] → `total_amount__gte`/`total_amount__lte`
/// - [penaltyFrom]/[penaltyTo] → `penalty_amount__gte`/`penalty_amount__lte`
///   ([penaltyEnabled] — dizayn toggle holati, maydonlarni ochib/yopadi)
/// - [search] → `search`
class PayrollFilter extends Equatable {
  const PayrollFilter({
    this.month,
    this.createdFrom,
    this.createdTo,
    this.totalFrom,
    this.totalTo,
    this.penaltyEnabled = false,
    this.penaltyFrom,
    this.penaltyTo,
    this.search = '',
  });

  static const empty = PayrollFilter();

  final DateTime? month;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final num? totalFrom;
  final num? totalTo;
  final bool penaltyEnabled;
  final num? penaltyFrom;
  final num? penaltyTo;
  final String search;

  bool get hasActiveFilters =>
      month != null ||
      createdFrom != null ||
      createdTo != null ||
      totalFrom != null ||
      totalTo != null ||
      penaltyFrom != null ||
      penaltyTo != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  PayrollFilter copyWithSearch(String search) => PayrollFilter(
    month: month,
    createdFrom: createdFrom,
    createdTo: createdTo,
    totalFrom: totalFrom,
    totalTo: totalTo,
    penaltyEnabled: penaltyEnabled,
    penaltyFrom: penaltyFrom,
    penaltyTo: penaltyTo,
    search: search,
  );

  @override
  List<Object?> get props => [
    month,
    createdFrom,
    createdTo,
    totalFrom,
    totalTo,
    penaltyEnabled,
    penaltyFrom,
    penaltyTo,
    search,
  ];
}
