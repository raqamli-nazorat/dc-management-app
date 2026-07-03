import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/bloc/session_bloc.dart';
import '../../features/attendance/presentation/pages/attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pin/pages/pin_page.dart';
import '../../features/auth/presentation/role/pages/role_select_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/notification/presentation/pages/notification_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'entity/routes.dart';

/// Root navigator key — exposed for context-free navigation (snackbars,
/// dialogs, theme toggles) outside the widget tree.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Centralized application router.
///
/// All routing lives here. A single [redirect] guard reads [SessionBloc] state
/// and decides the destination; [GoRouterRefreshStream] re-runs that guard on
/// every session change, so login / logout / timeout / attendance transitions
/// reroute automatically with no imperative navigation calls scattered around.
class AppRouter {
  AppRouter(this._session) {
    router = _build();
  }

  final SessionBloc _session;
  late final GoRouter router;

  GoRouter _build() {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: Routes.splash.path,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(_session.stream),
      redirect: _guard,
      routes: <RouteBase>[
        GoRoute(
          name: Routes.splash.name,
          path: Routes.splash.path,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          name: Routes.login.name,
          path: Routes.login.path,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          name: Routes.pinCode.name,
          path: Routes.pinCode.path,
          builder: (context, state) => const PinPage(),
        ),
        GoRoute(
          name: Routes.roleSelect.name,
          path: Routes.roleSelect.path,
          builder: (context, state) => const RoleSelectPage(),
        ),
        GoRoute(
          name: Routes.checkCode.name,
          path: Routes.checkCode.path,
          builder: (context, state) => const AttendancePage(),
        ),
        GoRoute(
          name: Routes.home.name,
          path: Routes.home.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: Routes.notifications.name,
          path: Routes.notifications.path,
          builder: (context, state) => const NotificationPage(),
        ),
        GoRoute(
          name: Routes.profile.name,
          path: Routes.profile.path,
          builder: (context, state) => const ProfilePage(),
        ),
      ],
    );
  }

  /// The single redirect guard. Pure function of session state + target path.
  ///
  /// Flow: splash → login (no cached user) → pin (cached user, re-auth) →
  /// roleSelect (multiple roles, none chosen) → home.
  String? _guard(BuildContext context, GoRouterState state) {
    final session = _session.state;
    final location = state.matchedLocation;

    final onSplash = location == Routes.splash.path;
    final onLogin = location == Routes.login.path;
    final onPin = location == Routes.pinCode.path;
    final onRoleSelect = location == Routes.roleSelect.path;

    // Still resolving stored session -> hold on splash.
    if (!session.isResolved) {
      return onSplash ? null : Routes.splash.path;
    }

    // No cached login -> full login screen.
    if (session.isUnauthenticated) {
      return onLogin ? null : Routes.login.path;
    }

    // Cached login, needs PIN re-auth -> PIN screen. Purely state-driven:
    // `_onResumed` emits `pinRequired` on a real background→resume timeout, and
    // the resume nudge (`router.refresh()`) re-runs this guard once that state
    // has settled. No free-running time predicate here — that would falsely
    // lock during long foreground use (lastActiveAt isn't bumped in foreground).
    if (session.isPinRequired) {
      return onPin ? null : Routes.pinCode.path;
    }

    // Authenticated with multiple roles, none chosen -> role selection.
    if (session.roleSelectionRequired) {
      return onRoleSelect ? null : Routes.roleSelect.path;
    }

    // Fully authenticated: keep away from gates.
    if (onSplash || onLogin || onPin || onRoleSelect) {
      return Routes.home.path;
    }

    return null;
  }
}

/// Adapts a [Stream] (a bloc/cubit stream) into a [Listenable] that GoRouter's
/// `refreshListenable` understands. Notifies once on creation, then on each event.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream
        .asBroadcastStream()
        .listen((dynamic _) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
