import 'package:dc_management_app/features/ledger/data/models/ledger_model.dart';
import 'package:dc_management_app/features/ledger/domain/entities/ledger_entry.dart';
import 'package:dc_management_app/features/ledger/domain/entities/ledger_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LedgerModel', () {
    test('maps Ledger payload with nested user_info', () {
      final entry = LedgerModel.fromJson({
        'id': 5,
        'user_info': {
          'username': 'Darya Novikova',
          'avatar': 'https://cdn/a.png',
          'fixed_salary': '8000000.00',
        },
        'amount': '75000.00',
        'transaction_type': 'debit',
        'description': 'test',
        'created_at': '2026-01-01T00:00:00Z',
      });

      expect(entry.id, 5);
      expect(entry.userName, 'Darya Novikova');
      expect(entry.avatar, 'https://cdn/a.png');
      expect(entry.fixedSalary, '8000000.00');
      expect(entry.amount, '75000.00');
      expect(entry.transactionType, TransactionType.debit);
      expect(entry.createdAt, DateTime.utc(2026, 1, 1));
    });

    test('credit maps to income, unknown/missing tolerated', () {
      expect(
        LedgerModel.fromJson({'transaction_type': 'credit'}).transactionType,
        TransactionType.credit,
      );
      final bare = LedgerModel.fromJson({'id': 1});
      expect(bare.transactionType, TransactionType.unknown);
      expect(bare.userName, '');
      expect(bare.amount, '');
      expect(bare.createdAt, isNull);
    });
  });

  group('LedgerFilter', () {
    test('search alone does not mark filter active', () {
      expect(const LedgerFilter(search: 'x').hasActiveFilters, isFalse);
      expect(
        const LedgerFilter(
          transactionType: TransactionType.debit,
        ).hasActiveFilters,
        isTrue,
      );
      expect(const LedgerFilter(amountFrom: 100).hasActiveFilters, isTrue);
    });

    test('copyWithSearch keeps other fields, replaces search', () {
      final filter = LedgerFilter(
        transactionType: TransactionType.credit,
        amountFrom: 50,
        search: 'old',
      );
      final next = filter.copyWithSearch('new');

      expect(next.transactionType, TransactionType.credit);
      expect(next.amountFrom, 50);
      expect(next.search, 'new');
    });
  });
}
