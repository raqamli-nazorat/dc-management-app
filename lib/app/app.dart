import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thunder/thunder.dart';

import '../config/routes/coordinator.dart';
import '../config/theme/app_theme.dart';
import '../core/constants/storage_keys.dart';
import '../core/services/storage_service.dart';
import '../core/util/app_options.dart';
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

  // Ilova haqiqatda background (paused/detached) holatiga o'tganini kuzatish uchun flag
  bool _wasPaused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused || AppLifecycleState.detached:
        _wasPaused = true; // Haqiqiy backgroundga o'tdi deb belgilaymiz
        _session.add(const SessionBackgrounded());
        break;

      case AppLifecycleState.resumed:
      // Faqatgina ilova avval paused bo'lgan bo'lsagina resume eventini yuboramiz
        if (_wasPaused) {
          _wasPaused = false; // Flagni qayta tiklaymiz
          _session.add(const SessionResumed());

          // Event-loop nudge
          Future.delayed(Duration.zero, () => getIt<AppRouter>().router.refresh());
        }
        break;

      case AppLifecycleState.inactive || AppLifecycleState.hidden:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = getIt<AppRouter>().router;

    return BlocProvider<SessionBloc>.value(
      value: _session,
      // `ModelBinding` runtime’da `themeMode`ni saqlaydi — profil sahifasidagi
      // "Dizayn mavzusi" varag'i `AppOptions.update` orqali uni almashtiradi va
      // butun ilova qayta quriladi (light ↔ dark). Boshlang'ich qiymat
      // xotiradan o'qiladi (`configureDependencies()` `runApp`dan oldin
      // bajarilgani uchun `StorageService` shu yerda xavfsiz mavjud).
      child: ModelBinding(
        initialModel: AppOptions(
          themeMode: switch (getIt<StorageService>()
              .getString(StorageKeys.themeMode)) {
            'dark' => ThemeMode.dark,
            'light' => ThemeMode.light,
            _ => ThemeMode.system,
          },
          locale: const Locale('uz'),
        ),
        child: ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            final options = AppOptions.of(context);
            return MaterialApp.router(
              scaffoldMessengerKey: _rootScaffoldMessengerKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: options.themeMode,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              locale: const Locale('uz'),
              routerConfig: router,
              // Thunder — Dio tarmoq loglarini ko‘rish uchun debug overlay
              // (faqat `kIsDebug`da yoqiq, release’da avtomatik o‘chadi).
              builder: (context, child) => Thunder(
                dio: [getIt<Dio>()],
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
