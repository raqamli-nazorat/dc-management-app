import 'package:flutter/services.dart';

String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String formatPhoneNumber(String value) {
  final local = formatLocalPhoneNumber(value);
  return local.isEmpty ? '' : '+998 $local';
}

String formatLocalPhoneNumber(String value) {
  var digits = digitsOnly(value);
  if (digits.startsWith('998')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length > 9) digits = digits.substring(0, 9);

  final groups = <String>[];
  for (final length in [2, 3, 2, 2]) {
    if (digits.isEmpty) break;
    final take = digits.length < length ? digits.length : length;
    groups.add(digits.substring(0, take));
    digits = digits.substring(take);
  }
  return groups.join(' ');
}

String normalizePhoneNumber(String value) {
  var digits = digitsOnly(value);
  if (digits.startsWith('998')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  return digits.isEmpty ? '' : '+998$digits';
}

String formatCardNumber(String value) {
  final digits = digitsOnly(value);
  final limited = digits.length > 16 ? digits.substring(0, 16) : digits;
  return [
    for (var index = 0; index < limited.length; index += 4)
      limited.substring(
        index,
        index + 4 < limited.length ? index + 4 : limited.length,
      ),
  ].join(' ');
}

class PhoneNumberInputFormatter extends TextInputFormatter {
  const PhoneNumberInputFormatter({this.includeCountryPrefix = true});

  final bool includeCountryPrefix;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = includeCountryPrefix
        ? formatPhoneNumber(newValue.text)
        : formatLocalPhoneNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class CardNumberInputFormatter extends TextInputFormatter {
  const CardNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final formatted = formatCardNumber(newValue.text);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
