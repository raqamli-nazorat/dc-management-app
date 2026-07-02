import 'package:flutter/material.dart';

import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/tab_placeholder.dart';

/// "Foydalanuvchilar" tabi (default UI).
class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) => TabPlaceholder(
        title: AppLocalizations.of(context).navUsers,
        icon: Assets.icons.icUserGroup,
      );
}
