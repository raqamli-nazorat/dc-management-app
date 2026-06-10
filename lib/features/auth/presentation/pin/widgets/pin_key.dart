import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';

/// PIN klaviatura tugmasi turlari.
enum PinKeyType { number, login, backspace }

/// Bitta PIN klaviatura tugmasi (64 balandlik, 32 radius — Figma).
class PinKey extends StatelessWidget {
  const PinKey._({
    required this.type,
    required this.onTap,
    this.digit,
  });

  /// Raqamli tugma (to‘ldirilgan fon).
  const PinKey.number(String value, {Key? key, required VoidCallback onTap})
      : this._(type: PinKeyType.number, digit: value, onTap: onTap);

  /// Login/hisob almashtirish tugmasi (faqat ramka).
  const PinKey.login({Key? key, required VoidCallback onTap})
      : this._(type: PinKeyType.login, onTap: onTap);

  /// O‘chirish tugmasi (fonsiz, faqat ikonka).
  const PinKey.backspace({Key? key, required VoidCallback onTap})
      : this._(type: PinKeyType.backspace, onTap: onTap);

  final PinKeyType type;
  final String? digit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(32.r);

    final (Color background, BoxBorder? border) = switch (type) {
      PinKeyType.number => (colors.backgroundElevation1Alt, null),
      PinKeyType.login => (
        Colors.transparent,
        Border.all(color: colors.strokeSoft),
      ),
      PinKeyType.backspace => (Colors.transparent, null),
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
      PinKeyType.number => (digit ?? '')
          .s(28.sp)
          .w(800)
          .c(colors.textStrong)
          .h(32 / 28),
      PinKeyType.login => Assets.icons.cTuilconLoginLarge.svg(
        width: 24.r,
        height: 24.r,
        colorFilter: ColorFilter.mode(colors.errorSub, BlendMode.srcIn),
      ),
      PinKeyType.backspace => Assets.icons.icArrowLeftLarge.svg(
        width: 24.r,
        height: 24.r,
        colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
      ),
    };
  }
}
