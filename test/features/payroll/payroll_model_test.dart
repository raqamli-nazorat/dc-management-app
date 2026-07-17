import 'package:dc_management_app/features/payroll/data/models/payroll_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PayrollModel', () {
    test('maps Payroll payload with nested user_info', () {
      final p = PayrollModel.fromJson({
        'id': 9,
        'user_info': {
          'username': 'Darya Novikova',
          'avatar': 'https://cdn/a.png',
        },
        'month_display': 'Yanvar',
        'fixed_salary': '10000000.00',
        'kpi_bonus': '75000.00',
        'penalty_amount': '75000.00',
        'total_amount': '10000000.00',
        'is_confirmed': false,
        'created_at': '2025-01-10T00:00:00Z',
      });

      expect(p.id, 9);
      expect(p.userName, 'Darya Novikova');
      expect(p.monthDisplay, 'Yanvar');
      expect(p.fixedSalary, '10000000.00');
      expect(p.kpiBonus, '75000.00');
      expect(p.penaltyAmount, '75000.00');
      expect(p.totalAmount, '10000000.00');
      expect(p.isConfirmed, isFalse);
      expect(p.createdAt, DateTime.utc(2025, 1, 10));
    });

    test('copyWithConfirmed flips only is_confirmed', () {
      final p = PayrollModel.fromJson({'id': 1, 'is_confirmed': false});
      final confirmed = p.copyWithConfirmed();

      expect(confirmed.isConfirmed, isTrue);
      expect(confirmed.id, p.id);
      expect(confirmed.userName, p.userName);
    });

    test('tolerates missing fields', () {
      final p = PayrollModel.fromJson({'id': 2});
      expect(p.userName, '');
      expect(p.isConfirmed, isFalse);
      expect(p.totalAmount, '');
      expect(p.createdAt, isNull);
    });
  });
}
