import 'package:dc_management_app/features/profile/data/models/profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileModel', () {
    test('reads social links from a JSON list', () {
      final profile = ProfileModel.fromJson({
        'social_links': ['https://github.com/example', 'https://t.me/example'],
      });

      expect(profile.socialLinks, [
        'https://github.com/example',
        'https://t.me/example',
      ]);
    });

    test('keeps a legacy single social-link string', () {
      final profile = ProfileModel.fromJson({
        'social_links': 'https://github.com/example',
      });

      expect(profile.socialLinks, ['https://github.com/example']);
    });
  });
}
