import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pin_key.dart';

/// PIN klaviaturasi — `GridView.builder` (3 ustun) bilan qurilgan, barcha
/// ekran o‘lchamlarida 1:1 moslashuvchan.
///
/// Tartib: 1–9, so‘ng [login], 0, [backspace].
class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onBiometric,
    required this.biometricAvailable,
    this.enabled = true,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onBiometric;
  final bool biometricAvailable;
  final bool enabled;

  static const List<String> _keys = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    'biometric',
    '0',
    'backspace',
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: _keys.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        mainAxisExtent: 76.h,
      ),
      itemBuilder: (context, index) {
        final key = _keys[index];
        return switch (key) {
          'biometric' when biometricAvailable => PinKey.biometric(
            onTap: enabled ? onBiometric : () {},
          ),
          'biometric' => const SizedBox.shrink(),
          'backspace' => PinKey.backspace(onTap: enabled ? onBackspace : () {}),
          _ => PinKey.number(key, onTap: enabled ? () => onDigit(key) : () {}),
        };
      },
    );
  }
}
