import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/statistics.dart';

/// Yig‘ilishlar dinamikasi — qatnashish taqsimoti (donut) + legenda.
class MeetingsDonutChart extends StatelessWidget {
  const MeetingsDonutChart({super.key, required this.stats});

  final MeetingStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final segments = <_Segment>[
      _Segment(l10n.statMeetingAttended, stats.attended, colors.chartGreen),
      _Segment(l10n.statMeetingExcused, stats.withReason, colors.chartBlue),
      _Segment(l10n.statMeetingUnexcused, stats.unexcused, colors.errorSub),
    ];
    final total = segments.fold<int>(0, (s, e) => s + e.value);

    return SizedBox(
      height: 160.h,
      child: Row(
        children: [
          SizedBox(
            width: 140.w,
            height: 140.w,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: total == 0 ? 0 : 3,
                centerSpaceRadius: 42.r,
                pieTouchData: PieTouchData(enabled: false),
                sections: total == 0
                    ? [
                        PieChartSectionData(
                          value: 1,
                          color: colors.strokeSub,
                          radius: 18.r,
                          showTitle: false,
                        ),
                      ]
                    : [
                        for (final s in segments)
                          if (s.value > 0)
                            PieChartSectionData(
                              value: s.value.toDouble(),
                              color: s.color,
                              radius: 18.r,
                              showTitle: false,
                            ),
                      ],
              ),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < segments.length; i++) ...[
                  _LegendRow(segment: segments[i], colors: colors),
                  if (i != segments.length - 1) SizedBox(height: 16.h),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment {
  const _Segment(this.label, this.value, this.color);

  final String label;
  final int value;
  final Color color;
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.segment, required this.colors});

  final _Segment segment;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: segment.color,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 10.w, height: 10.w),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: segment.label
              .s(13.sp)
              .w(500)
              .c(colors.textSub)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 8.w),
        '${segment.value}'.s(14.sp).w(700).c(colors.textStrong),
      ],
    );
  }
}
