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

/*  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Fon timeout’i (3 daqiqa) PIN qulfini boshqaradi:
    // fonga o‘tganda vaqt belgilanadi, qaytganda timeout tekshiriladi.
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _session.add(const SessionBackgrounded());
      case AppLifecycleState.resumed:
        _session.add(const SessionResumed());
      case AppLifecycleState.inactive:
        break;
    }
  }*/

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Faqat `paused` (haqiqiy background) va `detached` (kill) da vaqt belgilanadi.
    // `hidden`/`inactive` ikki yo‘nalishda ham (chiqish VA qaytish) fire bo‘ladi —
    // ularni stamp qilish resume’da `lastActiveAt`ni qayta yozib, timeout’ni buzadi.
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.detached:
        _session.add(const SessionBackgrounded());
      case AppLifecycleState.resumed:
        _session.add(const SessionResumed());
        // Event-loop nudge: bloc async event navbatdan o‘tgach (microtask) guard
        // qayta ishga tushadi — `pinRequired` holati allaqachon emit qilingan.
        Future.delayed(Duration.zero, () => getIt<AppRouter>().router.refresh());
      case AppLifecycleState.inactive || AppLifecycleState.hidden:
        break;
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
