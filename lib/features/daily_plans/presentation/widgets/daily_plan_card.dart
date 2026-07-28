import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_plan.dart';

class DailyPlanCard extends StatelessWidget {
  const DailyPlanCard({
    required this.plan,
    required this.onItemToggle,
    required this.onPlanToggle,
    required this.onTap,
    this.onLongPress,
    super.key,
  });

  final DailyPlan plan;
  final ValueChanged<DailyPlanItem> onItemToggle;
  final VoidCallback onPlanToggle;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final date = plan.createdAt == null
        ? ''
        : DateFormat('EEEE d-MMMM yyyy', 'uz').format(plan.createdAt!);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: _accent(colors),
          border: Border.all(color: colors.backgroundElevation1, width: 4.w),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 44.h),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation1,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      plan.title
                          .s(17.sp)
                          .w(800)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      if (plan.items.isNotEmpty) SizedBox(height: 12.h),
                      for (final item in plan.items)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _PlanItem(
                            item: item,
                            onTap: () => onItemToggle(item),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: date
                        .s(11.sp)
                        .w(800)
                        .c(colors.textWhite)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  InkWell(
                    onTap: onPlanToggle,
                    borderRadius: BorderRadius.circular(20.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accentStrong,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow,
                            offset: Offset(0, 4.h),
                            blurRadius: 12.r,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.icons.icCheckCircle.svg(
                              width: 12.w,
                              height: 12.w,
                              colorFilter: ColorFilter.mode(
                                colors.iconWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            (plan.isDone
                                    ? AppLocalizations.of(
                                        context,
                                      ).dailyPlansDone
                                    : AppLocalizations.of(
                                        context,
                                      ).dailyPlansUndone)
                                .s(11.sp)
                                .w(800)
                                .c(colors.textWhite),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accent(AppColors colors) => switch (plan.color) {
    DailyPlanColor.red => colors.dailyPlanRed,
    DailyPlanColor.yellow => colors.dailyPlanYellow,
    DailyPlanColor.green => colors.dailyPlanGreen,
    DailyPlanColor.blue => colors.dailyPlanBlue,
  };
}

class _PlanItem extends StatelessWidget {
  const _PlanItem({required this.item, required this.onTap});

  final DailyPlanItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: item.isDone
                  ? colors.accentSub
                  : colors.backgroundElevation2,
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
                width: 21.w,
                height: 21.h,
                child: item.isDone
                    ? Assets.icons.icCheck.svg(
                      width: 21.w,
                      height: 21.h,
                    )
                    : null,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: _title(colors)),
        ],
      ),
    );
  }

  Text _title(AppColors colors) {
    final text = item.title.s(15.sp).w(500).c(colors.textStrong);
    return text.copyWith(
      style: text.style!.copyWith(
        decoration: item.isDone ? TextDecoration.lineThrough : null,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
