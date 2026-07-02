import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/statistics.dart';

/// Loyihalar grafigi — loyiha holatlari bo‘yicha ustunli (bar) grafik.
class ProjectsBarChart extends StatelessWidget {
  const ProjectsBarChart({super.key, required this.stats});

  final ProjectStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final labels = <String>[
      l10n.statProjectCompleted,
      l10n.statProjectActive,
      l10n.statProjectCancelled,
      l10n.statProjectOverdue,
      l10n.statProjectPlanning,
    ];
    final values = <int>[
      stats.completed,
      stats.active,
      stats.cancelled,
      stats.overdue,
      stats.planning,
    ];
    final barColors = <Color>[
      colors.chartLime,
      colors.chartTeal,
      colors.chartNeutral,
      colors.errorSub,
      colors.chartGrey,
    ];

    final maxVal = values.fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = maxVal <= 0 ? 4.0 : (maxVal * 1.25).ceilToDouble();
    final interval = maxY / 4;

    return SizedBox(
      height: 200.h,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(enabled: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: colors.strokeSub,
              strokeWidth: 1,
              dashArray: const [4, 4],
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: interval,
                reservedSize: 28.w,
                getTitlesWidget: (value, meta) {
                  if (value > maxY) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: value.toInt().toString().s(10.sp).w(500).c(
                          colors.textSoft,
                        ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 24.h,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: SizedBox(
                      width: 58.w,
                      child: Center(
                        child: labels[i]
                            .s(8.5.sp)
                            .w(500)
                            .c(colors.textSoft)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < values.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: values[i].toDouble(),
                    color: barColors[i],
                    width: 22.w,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
