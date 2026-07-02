import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/tab_placeholder.dart';

/// "Loyihalar" tabi (default UI).
class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) => TabPlaceholder(
        title: AppLocalizations.of(context).navProjects,
        icon: Assets.icons.icFolder,
      );
}
