import 'package:dc_management_app/features/reports/domain/entities/expense_report.dart';
import 'package:dc_management_app/features/reports/domain/entities/expense_report_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('expense filter serializable selections mark it active', () {
    const filter = ExpenseReportFilter(
      paymentMethods: {ExpensePaymentMethod.card},
      statuses: {ExpenseStatus.confirmed},
      types: {ExpenseType.company},
    );

    expect(filter.hasActiveFilters, isTrue);
    expect(ExpensePaymentMethod.card.apiValue, 'card');
    expect(ExpenseStatus.confirmed.apiValue, 'confirmed');
    expect(ExpenseType.company.apiValue, 'company');
  });
}
