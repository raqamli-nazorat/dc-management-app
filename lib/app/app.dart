import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../config/routes/coordinator.dart';
import '../config/theme/app_theme.dart';
import '../injection_container.dart';
import '../l10n/app_localizations.dart';
import 'bloc/session_bloc.dart';

final _rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late final SessionBloc _session = getIt<SessionBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // PIN har ilovaga "kirishda" ham talab qilinadi: foreground'ga qaytganda
    // autentifikatsiyalangan bo‘lsa — sessiyani qayta baholaymiz (PIN gate).
    if (state == AppLifecycleState.resumed &&
        _session.state.isAuthenticated) {
      _session.add(const SessionStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    return BlocProvider<SessionBloc>.value(
      value: _session,
      child: ScreenUtilInit(
        designSize: const Size(360, 800),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp.router(
            scaffoldMessengerKey: _rootScaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('uz'),
            routerConfig: router,
          );
        },
      ),
    );
  }
}
