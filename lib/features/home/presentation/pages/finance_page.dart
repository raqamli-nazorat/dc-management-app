import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/tab_placeholder.dart';

/// "Moliya" tabi (default UI).
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) => TabPlaceholder(
        title: AppLocalizations.of(context).navFinance,
        icon: Assets.icons.icBriefcaseDollar,
      );
}
