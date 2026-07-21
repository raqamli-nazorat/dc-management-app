import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

abstract final class Formatters {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// API decimal qiymatini ko'rinish uchun guruhlaydi:
  /// `10000.00` → `10 000.00`.
  static String formatAmount(String value) {
    final normalized = value.trim().replaceAll(' ', '').replaceAll(',', '.');
    final match = RegExp(r'^(\d+)(?:\.(\d*))?$').firstMatch(normalized);
    if (match == null) return value;

    final digits = match.group(1)!;
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) buffer.write(' ');
      buffer.write(digits[index]);
    }
    final fraction = match.group(2);
    return fraction == null
        ? buffer.toString()
        : '${buffer.toString()}.$fraction';
  }

  /// [formatAmount] + vergulli kasr (dizayn ko'rinishi):
  /// `12000000.00` → `12 000 000,00`.
  static String formatAmountComma(String value) =>
      formatAmount(value).replaceAll('.', ',');

  static String normalizeAmount(String value) =>
      value.trim().replaceAll(' ', '').replaceAll(',', '.');
}

class AmountInputFormatter extends TextInputFormatter {
  const AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.replaceAll(' ', '').replaceAll(',', '.');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    if (!RegExp(r'^\d{0,10}(?:\.\d{0,2})?$').hasMatch(raw)) {
      return oldValue;
    }

    final formatted = Formatters.formatAmountComma(raw);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
