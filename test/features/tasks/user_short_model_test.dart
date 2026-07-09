import 'package:dc_management_app/features/tasks/data/models/task_form_option_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserShortModel', () {
    const managerResponse = {
      'id': 19,
      'username': 'Akbarov Shoxruz',
      'avatar': 'https://example.test/avatar.jpg',
      'position_info': {'id': 2, 'name': 'Frontend dasturchi'},
      'roles': ['manager', 'employee'],
    };

    test('maps position_info returned by users endpoint', () {
      final user = UserShortModel.fromJson(managerResponse);

      expect(user.id, 19);
      expect(user.position, 'Frontend dasturchi');
    });

    test('recognizes only users with manager role', () {
      expect(UserShortModel.hasRole(managerResponse, 'manager'), isTrue);
      expect(
        UserShortModel.hasRole(const {
          'roles': ['employee'],
        }, 'manager'),
        isFalse,
      );
    });
  });
}
