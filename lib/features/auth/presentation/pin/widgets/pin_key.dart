import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';

/// PIN klaviatura tugmasi turlari.
enum PinKeyType { number, biometric, backspace }

/// Bitta PIN klaviatura tugmasi (76 balandlik, 38 radius — Figma).
class PinKey extends StatelessWidget {
  const PinKey._({required this.type, required this.onTap, this.digit});

  /// Raqamli tugma (to‘ldirilgan fon).
  const PinKey.number(String value, {Key? key, required VoidCallback onTap})
    : this._(type: PinKeyType.number, digit: value, onTap: onTap);

  /// Biometrik unlock tugmasi (faqat ramka).
  const PinKey.biometric({Key? key, required VoidCallback onTap})
    : this._(type: PinKeyType.biometric, onTap: onTap);

  /// O‘chirish tugmasi (fonsiz, faqat ikonka).
  const PinKey.backspace({Key? key, required VoidCallback onTap})
    : this._(type: PinKeyType.backspace, onTap: onTap);

  final PinKeyType type;
  final String? digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(38.r);

    final (Color background, BoxBorder? border) = switch (type) {
      PinKeyType.number => (colors.backgroundElevation1Alt, null),
      PinKeyType.biometric => (
        colors.backgroundBase,
        Border.all(color: colors.strokeSub),
      ),
      PinKeyType.backspace => (colors.backgroundBase, null),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: border,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Center(child: _content(colors)),
        ),
      ),
    );
  }

  Widget _content(AppColors colors) {
    return switch (type) {
      PinKeyType.number =>
        (digit ?? '').s(32.sp).w(800).c(colors.textStrong).h(38 / 32),
      PinKeyType.biometric => Assets.icons.icHugeiconsFingerprintScan.svg(
        width: 28.r,
        height: 28.r,
        colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
      ),
      PinKeyType.backspace => Assets.icons.icArrowLeftLarge.svg(
        width: 24.r,
        height: 24.r,
        colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
      ),
    };
  }
}
