import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_nav_tile.dart';
import '../../../../l10n/app_localizations.dart';

/// "Hisobotlar" tabi — hisobot turlari bo'yicha kartalar.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            AppNavTile(
              label: l10n.reportEmployee,
              image: Assets.images.perEmployee,
              imageSize: 72.w,
              onTap: () => context.pushNamed(Routes.userReports.name),
            ),
            AppNavTile(
              label: l10n.reportProject,
              image: Assets.images.accordingToTheProject,
              imageSize: 82.w,
              onTap: () => context.pushNamed(Routes.projectReports.name),
            ),
            AppNavTile(
              label: l10n.reportSpendingRequests,
              image: Assets.images.onSpendingRequests,
              imageSize: 82.w,
              onTap: () => context.pushNamed(Routes.expenseReports.name),
            ),
            AppNavTile(
              label: l10n.reportWages,
              image: Assets.images.regardingWages,
              imageSize: 82.w,
            ),
            AppNavTile(
              label: l10n.reportTasks,
              image: Assets.images.byTasks,
              imageSize: 82.w,
              onTap: () => context.pushNamed(Routes.taskReports.name),
            ),
          ],
        ),
      ),
    );
  }
}
