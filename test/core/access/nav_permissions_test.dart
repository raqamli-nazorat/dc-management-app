import 'package:dc_management_app/core/access/nav_permissions.dart';
import 'package:dc_management_app/core/access/role_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('project permissions', () {
    test('only admin can create projects', () {
      expect(NavPermissions.canCreateProject(RoleType.admin), isTrue);
      expect(NavPermissions.canCreateProject(RoleType.manager), isFalse);
      expect(NavPermissions.canCreateProject(RoleType.employee), isFalse);
    });

    test('admin and manager can manage projects', () {
      expect(NavPermissions.canManageProject(RoleType.admin), isTrue);
      expect(NavPermissions.canManageProject(RoleType.manager), isTrue);
      expect(NavPermissions.canManageProject(RoleType.employee), isFalse);
      expect(NavPermissions.canManageProject(RoleType.auditor), isFalse);
      expect(NavPermissions.canManageProject(RoleType.accountant), isFalse);
    });
  });
}
