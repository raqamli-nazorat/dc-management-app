import 'package:dc_management_app/core/util/contact_input_formatters.dart';
import 'package:dc_management_app/core/util/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats and normalizes Uzbek phone numbers', () {
    expect(formatPhoneNumber('998901234567'), '+998 90 123 45 67');
    expect(normalizePhoneNumber('+998 90 123 45 67'), '+998901234567');
  });

  test('formats card numbers in groups of four', () {
    expect(formatCardNumber('5555555555550001'), '5555 5555 5555 0001');
  });

  test('formats and normalizes salary amounts', () {
    expect(Formatters.formatAmountComma('11111111.00'), '11 111 111,00');
    expect(Formatters.normalizeAmount('11 111 111,00'), '11111111.00');
  });
}
