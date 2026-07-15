import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/nav_permissions.dart';
import '../../../../core/access/role_type.dart';
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
///
/// Tab ro‘yxati joriy rolga qarab filtrlanadi ([NavPermissions.isVisible]) —
/// `_sections` doim to‘liq, filtrlangan ro‘yxat har `build()`da hosil bo‘ladi
/// (pages va nav items bir xil iteratsiyadan olinadi — indekslar mos keladi).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  static const _sections = <(AppSection, Widget)>[
    (AppSection.home, MainPage()),
    (AppSection.users, UsersPage()),
    (AppSection.projects, ProjectsPage()),
    (AppSection.finance, FinancePage()),
    (AppSection.reports, ReportsPage()),
  ];

  AppBottomNavItem _navItem(AppSection section, AppLocalizations l10n) {
    switch (section) {
      case AppSection.home:
        return AppBottomNavItem(
          icon: Assets.icons.icDashboardSquare,
          label: l10n.navHome,
        );
      case AppSection.users:
        return AppBottomNavItem(
          icon: Assets.icons.icUserGroup,
          label: l10n.navUsers,
        );
      case AppSection.projects:
        return AppBottomNavItem(
          icon: Assets.icons.icFolder,
          label: l10n.navTasks,
        );
      case AppSection.finance:
        return AppBottomNavItem(
          icon: Assets.icons.icBriefcaseDollar,
          label: l10n.navFinance,
        );
      case AppSection.reports:
        return AppBottomNavItem(
          icon: Assets.icons.icAnalytics,
          label: l10n.navReports,
        );
      case AppSection.analytics:
      case AppSection.applications:
        throw StateError('$section is not a nav tab');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final role =
        context.select<SessionBloc, RoleType>((b) => b.state.roleType);

    final visible = _sections
        .where((e) => NavPermissions.isVisible(e.$1, role))
        .toList();
    final pages = visible.map((e) => e.$2).toList();
    final items = visible.map((e) => _navItem(e.$1, l10n)).toList();
    final safeIndex = _currentIndex >= visible.length ? 0 : _currentIndex;

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: IndexedStack(index: safeIndex, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        items: items,
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
