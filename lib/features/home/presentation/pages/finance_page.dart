import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_nav_tile.dart';
import '../../../../l10n/app_localizations.dart';

/// "Moliya" tabi — moliya bo'limlari bo'yicha kartalar. Tepada to'liq
/// kenglikdagi "Xarajat so'rovlari", pastda ikki yarim-kenglikdagi karta
/// ("Ish haqi" + "Tarix").
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12.h,
          children: [
            AppNavTile(
              label: l10n.financeExpenseRequests,
              image: Assets.images.spendingRequestsImage,
              imageSize: 82.w,
              onTap: () => context.pushNamed(Routes.expenseRequests.name),
            ),
            Row(
              spacing: 12.w,
              children: [
                Expanded(
                  child: AppNavTile(
                    label: l10n.financeWages,
                    image: Assets.images.wagesImage,
                    imageSize: 72.w,
                    onTap: () => context.pushNamed(Routes.payrollList.name),
                  ),
                ),
                Expanded(
                  child: AppNavTile(
                    label: l10n.financeHistory,
                    image: Assets.images.historyImage,
                    imageSize: 72.w,
                    onTap: () => context.pushNamed(Routes.ledgerList.name),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
