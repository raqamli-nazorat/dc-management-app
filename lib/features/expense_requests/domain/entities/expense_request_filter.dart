import 'package:equatable/equatable.dart';

import '../../../reports/domain/entities/expense_report.dart';

/// Xarajat so'rovlari filtri (`GET /expense-request/` query paramlari).
///
/// Maydon → param moslashuvi (sxema tasdiqlangan):
/// - [type] → `type` (withdrawal/company/other)
/// - [categoryId] → `expense_category` (FK id, `GET /expense-category/`)
/// - [projectId] → `project` (FK id)
/// - [amountFrom]/[amountTo] → `amount__gte`/`amount__lte`
/// - [createdFrom]/[createdTo] → `created_at__gte`/`created_at__lte`
/// - [paidFrom]/[paidTo] → `paid_at__gte`/`paid_at__lte`
/// - [confirmedFrom]/[confirmedTo] → `confirmed_at__gte`/`confirmed_at__lte`
/// - [search] → `search`
class ExpenseRequestFilter extends Equatable {
  const ExpenseRequestFilter({
    this.type,
    this.categoryId,
    this.projectId,
    this.amountFrom,
    this.amountTo,
    this.createdFrom,
    this.createdTo,
    this.paidFrom,
    this.paidTo,
    this.confirmedFrom,
    this.confirmedTo,
    this.search = '',
  });

  static const empty = ExpenseRequestFilter();

  final ExpenseType? type;
  final int? categoryId;
  final int? projectId;
  final num? amountFrom;
  final num? amountTo;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final DateTime? paidFrom;
  final DateTime? paidTo;
  final DateTime? confirmedFrom;
  final DateTime? confirmedTo;
  final String search;

  bool get hasActiveFilters =>
      type != null ||
      categoryId != null ||
      projectId != null ||
      amountFrom != null ||
      amountTo != null ||
      createdFrom != null ||
      createdTo != null ||
      paidFrom != null ||
      paidTo != null ||
      confirmedFrom != null ||
      confirmedTo != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  ExpenseRequestFilter copyWithSearch(String search) => ExpenseRequestFilter(
    type: type,
    categoryId: categoryId,
    projectId: projectId,
    amountFrom: amountFrom,
    amountTo: amountTo,
    createdFrom: createdFrom,
    createdTo: createdTo,
    paidFrom: paidFrom,
    paidTo: paidTo,
    confirmedFrom: confirmedFrom,
    confirmedTo: confirmedTo,
    search: search,
  );

  @override
  List<Object?> get props => [
    type,
    categoryId,
    projectId,
    amountFrom,
    amountTo,
    createdFrom,
    createdTo,
    paidFrom,
    paidTo,
    confirmedFrom,
    confirmedTo,
    search,
  ];
}
