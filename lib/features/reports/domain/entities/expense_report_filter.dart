import 'package:equatable/equatable.dart';

import 'expense_report.dart';

class ExpenseReportFilter extends Equatable {
  const ExpenseReportFilter({
    this.search = '',
    this.userIds = const {},
    this.accountantIds = const {},
    this.projectIds = const {},
    this.categoryIds = const {},
    this.paymentMethods = const {},
    this.statuses = const {},
    this.types = const {},
    this.amountFrom,
    this.amountTo,
    this.createdFrom,
    this.createdTo,
    this.paidFrom,
    this.paidTo,
    this.confirmedFrom,
    this.confirmedTo,
    this.cancelledFrom,
    this.cancelledTo,
  });

  static const empty = ExpenseReportFilter();

  final String search;
  final Set<int> userIds;
  final Set<int> accountantIds;
  final Set<int> projectIds;
  final Set<int> categoryIds;
  final Set<ExpensePaymentMethod> paymentMethods;
  final Set<ExpenseStatus> statuses;
  final Set<ExpenseType> types;
  final num? amountFrom;
  final num? amountTo;
  final DateTime? createdFrom;
  final DateTime? createdTo;
  final DateTime? paidFrom;
  final DateTime? paidTo;
  final DateTime? confirmedFrom;
  final DateTime? confirmedTo;
  final DateTime? cancelledFrom;
  final DateTime? cancelledTo;

  bool get hasActiveFilters =>
      userIds.isNotEmpty ||
      accountantIds.isNotEmpty ||
      projectIds.isNotEmpty ||
      categoryIds.isNotEmpty ||
      paymentMethods.isNotEmpty ||
      statuses.isNotEmpty ||
      types.isNotEmpty ||
      amountFrom != null ||
      amountTo != null ||
      createdFrom != null ||
      createdTo != null ||
      paidFrom != null ||
      paidTo != null ||
      confirmedFrom != null ||
      confirmedTo != null ||
      cancelledFrom != null ||
      cancelledTo != null;

  ExpenseReportFilter copyWithSearch(String search) => ExpenseReportFilter(
    search: search,
    userIds: userIds,
    accountantIds: accountantIds,
    projectIds: projectIds,
    categoryIds: categoryIds,
    paymentMethods: paymentMethods,
    statuses: statuses,
    types: types,
    amountFrom: amountFrom,
    amountTo: amountTo,
    createdFrom: createdFrom,
    createdTo: createdTo,
    paidFrom: paidFrom,
    paidTo: paidTo,
    confirmedFrom: confirmedFrom,
    confirmedTo: confirmedTo,
    cancelledFrom: cancelledFrom,
    cancelledTo: cancelledTo,
  );

  @override
  List<Object?> get props => [
    search,
    userIds,
    accountantIds,
    projectIds,
    categoryIds,
    paymentMethods,
    statuses,
    types,
    amountFrom,
    amountTo,
    createdFrom,
    createdTo,
    paidFrom,
    paidTo,
    confirmedFrom,
    confirmedTo,
    cancelledFrom,
    cancelledTo,
  ];
}

class ExpenseFilterOption extends Equatable {
  const ExpenseFilterOption({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}

typedef ExpenseReportOptions = ({
  List<ExpenseFilterOption> projects,
  List<ExpenseFilterOption> categories,
});
