import 'package:dc_management_app/core/util/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats API amount with grouped integer digits', () {
    expect(Formatters.formatAmount('10000.00'), '10 000.00');
    expect(Formatters.formatAmount('150000'), '150 000');
  });
}
