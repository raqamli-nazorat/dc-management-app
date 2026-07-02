import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/statistics.dart';

/// Vazifalar grafigi — vazifa holatlari bo‘yicha chiziqli (line) grafik.
class TasksLineChart extends StatelessWidget {
  const TasksLineChart({super.key, required this.stats});

  final TaskStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final labels = <String>[
      l10n.statTaskTodo,
      l10n.statTaskInProgress,
      l10n.statTaskDone,
      l10n.statTaskProduction,
      l10n.statTaskChecked,
      l10n.statTaskRejected,
      l10n.statTaskOverdue,
    ];
    final values = <int>[
      stats.todo,
      stats.inProgress,
      stats.done,
      stats.production,
      stats.checked,
      stats.rejectedTasks,
      stats.overdue,
    ];

    final maxVal = values.fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = maxVal <= 0 ? 4.0 : (maxVal * 1.25).ceilToDouble();
    final interval = maxY / 4;

    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i].toDouble()),
    ];

    return SizedBox(
      height: 190.h,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (values.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: const LineTouchData(enabled: false),
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
            leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 22.h,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: SizedBox(
                      width: 46.w,
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
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              color: colors.accentSub,
              barWidth: 1.5.w,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3.5.r,
                  color: colors.cardSurface,
                  strokeWidth: 2.w,
                  strokeColor: colors.textStrong,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.accentSub.withValues(alpha: 0.22),
                    colors.accentSub.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
