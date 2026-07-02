import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../l10n/app_localizations.dart';
import 'finance_page.dart';
import 'main_page.dart';
import 'projects_page.dart';
import 'reports_page.dart';
import 'users_page.dart';

/// Autentifikatsiyadan keyingi ilova qobig‘i (shell): pastki navigatsiya +
/// tanlangan tab tanasi. Har bir tab alohida sahifa; holat `IndexedStack`
/// bilan saqlanadi (tab almashganda qayta qurilmaydi).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    MainPage(),
    UsersPage(),
    ProjectsPage(),
    FinancePage(),
    ReportsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final items = <AppBottomNavItem>[
      AppBottomNavItem(icon: Assets.icons.icDashboardSquare, label: l10n.navHome),
      AppBottomNavItem(icon: Assets.icons.icUserGroup, label: l10n.navUsers),
      AppBottomNavItem(icon: Assets.icons.icFolder, label: l10n.navProjects),
      AppBottomNavItem(icon: Assets.icons.icBriefcaseDollar, label: l10n.navFinance),
      AppBottomNavItem(icon: Assets.icons.icAnalytics, label: l10n.navReports),
    ];

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
