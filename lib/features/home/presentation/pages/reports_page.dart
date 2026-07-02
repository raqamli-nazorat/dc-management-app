import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/tab_placeholder.dart';

/// "Hisobotlar" tabi (default UI).
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) => TabPlaceholder(
        title: AppLocalizations.of(context).navReports,
        icon: Assets.icons.icAnalytics,
      );
}
