import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';
import '../bloc/pin_bloc.dart';

/// PIN holati ko‘rsatkichi: nuqtalar (yashirin) yoki raqamlar (ko‘rinadigan),
/// o‘ng tomonda ko‘rsatish/yashirish ikonkasi.
///
/// Slotlar soni [length] orqali dinamik (qattiq kodlanmaydi) — saqlangan
/// parol uzunligidan keladi.
class PinIndicator extends StatelessWidget {
  const PinIndicator({
    super.key,
    required this.length,
    required this.pin,
    required this.obscure,
    required this.status,
    required this.onToggleVisibility,
  });

  final int length;
  final String pin;
  final bool obscure;
  final PinStatus status;
  final VoidCallback onToggleVisibility;

  bool get _showEye =>
      status != PinStatus.blocked && status != PinStatus.error;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const side = 32.0; // eye uchun balanslangan bo‘sh joy.

    return Row(
      children: [
        SizedBox(width: side.w),
        Expanded(
          child: Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16.w,
              runSpacing: 12.h,
              children: List.generate(
                length,
                (i) => _slot(colors, i),
              ),
            ),
          ),
        ),
        SizedBox(
          width: side.w,
          child: _showEye
              ? GestureDetector(
                  onTap: onToggleVisibility,
                  behavior: HitTestBehavior.opaque,
                  child: (obscure
                          ? Assets.icons.icEyeOpen
                          : Assets.icons.icEyeClose)
                      .svg(
                    width: 24.r,
                    height: 24.r,
                    colorFilter: ColorFilter.mode(
                      colors.iconSub,
                      BlendMode.srcIn,
                    ),
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _slot(AppColors colors, int index) {
    final filled = index < pin.length;

    if (filled && !obscure) {
      return pin[index].s(28.sp).w(800).c(colors.textStrong).h(32 / 28);
    }

    final Color color = !filled
        ? colors.backgroundElevation3Alt
        : (status == PinStatus.error ? colors.errorSub : colors.textStrong);

    // Markazlashgan SVG ellipse — har holatda colorFilter bilan mavzuga moslashadi.
    return Assets.icons.icEllipse.svg(
      width: 12.r,
      height: 12.r,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
