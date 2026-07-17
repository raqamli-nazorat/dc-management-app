import 'package:dc_management_app/features/users/data/models/app_user_model.dart';
import 'package:dc_management_app/features/users/domain/entities/users_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppUserModel', () {
    test('maps full User payload including nested position_info', () {
      final user = AppUserModel.fromJson({
        'id': 7,
        'username': 'Abror Abduvahobov',
        'avatar': 'https://cdn/x.png',
        'position_info': {'id': 3, 'name': 'Frontend Developer'},
        'roles': ['manager', 'employee'],
        'fixed_salary': '12000000.00',
        'balance': 50000000,
        'phone_number': '+998941234567',
        'card_number': 8600000000000000,
        'region_info': {'id': 1, 'name': 'Toshkent viloyati'},
        'district_info': {'id': 2, 'name': 'Toshkent tumani'},
        'passport_series': 'AA1425053',
        'passport_image': 'https://cdn/passport.pdf',
        'date_joined': '2026-01-01T00:00:00Z',
      });

      expect(user.id, 7);
      expect(user.username, 'Abror Abduvahobov');
      expect(user.positionName, 'Frontend Developer');
      expect(user.roles, ['manager', 'employee']);
      expect(user.fixedSalary, '12000000.00');
      expect(user.balance, '50000000');
      expect(user.phoneNumber, '+998941234567');
      expect(user.cardNumber, '8600000000000000');
      expect(user.regionName, 'Toshkent viloyati');
      expect(user.districtName, 'Toshkent tumani');
      expect(user.passportSeries, 'AA1425053');
      expect(user.passportImage, 'https://cdn/passport.pdf');
      expect(user.dateJoined, DateTime.utc(2026, 1, 1));
    });

    test('tolerates missing/null optional fields', () {
      final user = AppUserModel.fromJson({'id': 1, 'username': 'X'});

      expect(user.avatar, '');
      expect(user.positionName, '');
      expect(user.roles, isEmpty);
      expect(user.fixedSalary, '');
      expect(user.balance, '');
    });
  });

  group('UsersFilter', () {
    test('search alone does not mark filter active', () {
      expect(const UsersFilter(search: 'ali').hasActiveFilters, isFalse);
      expect(const UsersFilter(role: 'admin').hasActiveFilters, isTrue);
      expect(
        const UsersFilter(ordering: UsersOrdering.nameDesc).hasActiveFilters,
        isTrue,
      );
    });

    test('copyWithSearch keeps other fields, replaces search', () {
      const filter = UsersFilter(positionId: 2, role: 'admin', search: 'old');
      final next = filter.copyWithSearch('new');

      expect(next.positionId, 2);
      expect(next.role, 'admin');
      expect(next.search, 'new');
    });
  });
}
