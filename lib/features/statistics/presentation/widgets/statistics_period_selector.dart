import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/statistics_bloc.dart';

/// Davr segment selektori (1 oy / 3 oy / 6 oy / 1 yil). Tanlangan segment
/// ko‘tarilgan (och) fon bilan ajralib turadi.
class StatisticsPeriodSelector extends StatelessWidget {
  const StatisticsPeriodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final StatPeriod selected;
  final ValueChanged<StatPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = colors.backgroundBase.computeLuminance() < 0.5;
    final selectedSurface =
        isDark ? colors.backgroundElevation2Alt : colors.white;

    String labelFor(StatPeriod p) => switch (p) {
          StatPeriod.month1 => l10n.statPeriod1Month,
          StatPeriod.month3 => l10n.statPeriod3Months,
          StatPeriod.month6 => l10n.statPeriod6Months,
          StatPeriod.year1 => l10n.statPeriod1Year,
        };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final period in StatPeriod.values)
              _Segment(
                label: labelFor(period),
                selected: period == selected,
                selectedSurface: selectedSurface,
                shadow: colors.shadow,
                selectedText: colors.textStrong,
                unselectedText: colors.textSoft,
                onTap: () => onChanged(period),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.selectedSurface,
    required this.shadow,
    required this.selectedText,
    required this.unselectedText,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color selectedSurface;
  final Color shadow;
  final Color selectedText;
  final Color unselectedText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? selectedSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: shadow,
                    offset: const Offset(0, 2),
                    blurRadius: 4.r,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
          child: label
              .s(13.sp)
              .w(selected ? 700 : 500)
              .c(selected ? selectedText : unselectedText),
        ),
      ),
    );
  }
}
