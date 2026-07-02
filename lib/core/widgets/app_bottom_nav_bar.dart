import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Bitta pastki navigatsiya elementining tavsifi.
///
/// [icon] — flutter_gen orqali generatsiya qilingan SVG (design ikonkasi).
/// [label] — allaqachon lokalizatsiya qilingan matn (widget hech qanday
/// `AppLocalizations`ga bog‘lanmaydi — chaqiruvchi tarjimani beradi).
class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label});

  final SvgGenImage icon;
  final String label;
}

/// Design bilan bir xil pastki navigatsiya paneli (light + dark).
///
/// Modular va parametrlangan: elementlar ro‘yxati, tanlangan indeks va bosish
/// callback’i tashqaridan beriladi — bir nechta call-site’da qayta ishlatiladi.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        border: Border(
          top: BorderSide(color: colors.strokeSub, width: 0.5.w),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavTab(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final iconColor = selected ? colors.iconAccent : colors.iconSub;
    final textColor = selected ? colors.textAccent : colors.textSub;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            item.icon.svg(
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            SizedBox(height: 4.h),
            item.label
                .s(11.sp)
                .w(selected ? 600 : 500)
                .c(textColor)
                .copyWith(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
          ],
        ),
      ),
    );
  }
}
