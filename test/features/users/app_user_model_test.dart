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
      });

      expect(user.id, 7);
      expect(user.username, 'Abror Abduvahobov');
      expect(user.positionName, 'Frontend Developer');
      expect(user.roles, ['manager', 'employee']);
      expect(user.fixedSalary, '12000000.00');
      expect(user.balance, '50000000');
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
