# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

`dc_management_app` ("Raqamli Boshqaruv") is a Flutter app on a Feature-First + Clean Architecture base. These rules are **mandatory** for every code-generation task in this repo.

## Commands

```bash
flutter pub get                         # install deps
flutter analyze lib                     # lint (must be clean before done)
flutter test                            # all tests
flutter test test/widget_test.dart      # single file
flutter test --plain-name "routes to login when no session exists"  # single test by name
flutter run                             # run on attached device/emulator
dart run build_runner build --delete-conflicting-outputs   # codegen (flutter_gen assets)
flutter gen-l10n                        # regenerate lib/l10n/app_localizations*.dart after editing .arb files
```

After any change: `flutter analyze lib` must report **0 issues** (one pre-existing info in `core/usecases/usecase.dart` aside).

## Architecture

### Feature-First + Clean Architecture
Every feature lives under `lib/features/<feature>/` split into three layers — never collapse them:

- **data/** — `service` (API + local data sources), `repository_impl`, `model` (JSON serialization). Models map to/from entities; never leak `Model` types above the data layer.
- **domain/** — `repository` (abstract interface), `usecase` (one action each), `entity` (pure Dart, no Flutter/JSON imports). The domain layer depends on nothing outward.
- **presentation/** — `bloc` (state), `pages` + `widgets` (UI). UI talks to domain only through blocs.

Dependency direction is strictly inward: presentation → domain ← data. Apply SOLID / DRY / KISS. Shared cross-feature code goes in `lib/core/`; app-wide config (routes, theme) in `lib/config/`.

### Dependency injection
`get_it` (`lib/injection_container.dart`). Register every service/repository/bloc in `configureDependencies()`. `bootstrap()` (`lib/app/bootstrap.dart`) calls it before `runApp`. Resolve via `getIt<T>()`. Singletons for stateful shared instances (router, session); lazy for the rest.

### Navigation — centralized GoRouter
**All** routing lives in `lib/config/routes/coordinator.dart` (`AppRouter`). Rules:
- Route descriptors are declared **only** in `lib/config/routes/entity/routes.dart` (`Routes`, implementing `Coordinate`). Navigate by **name**, never raw path strings: `context.goNamed(Routes.home.name)`.
- A single `redirect` guard makes **all** routing decisions from `SessionBloc` state. `GoRouterRefreshStream` re-runs the guard on every bloc emission — so login / pin / role-selection / logout transitions reroute automatically. **Never** branch on auth state inside a page or scatter imperative `context.go()` for guard concerns.
- Flow: `splash` (status `unknown`) → `login` (no cached login) → `pinCode` (`pinRequired`: cached login, re-auth) → `roleSelect` (`roleSelectionRequired`: >1 role, none chosen) → `home`. `checkCode` (attendance) route still exists but is **not** in the guard chain.
- Add a screen: declare in `routes.dart` → add `GoRoute` in `coordinator.dart` → it is auto-protected by the guard (anything not splash/login/pin/roleSelect requires full auth).

### State management — BLoC only
Use the **BLoC** pattern (events → states) for all feature state. **Cubits are not permitted** anywhere. Provide blocs via `BlocProvider` / `getIt`; UI reads with `context.read`/`BlocBuilder`/`BlocListener`.
> App-wide session/auth state lives in the app-level `SessionBloc` (`lib/app/bloc/session_bloc.dart`) — it drives the router guard. Statuses: `unknown` / `unauthenticated` / `pinRequired` / `authenticated` (+ `roleSelectionRequired`). No cubits remain.

### Networking
`Dio` is registered directly in `injection_container` (`DioFactory.create()` from `core/network/`, interceptors attached at registration), then wrapped by `DioClient` (`getIt<Dio>()` also resolves the raw instance — needed by Thunder, see below). Interceptors, in order: `AuthInterceptor` (attaches `Bearer` from `TokenService`) → `RefreshInterceptor` → `LoggingInterceptor`. The `RefreshInterceptor` is a `QueuedInterceptor`: on a 401 from a **non-auth** path it refreshes the access token via a separate interceptor-free `Dio` and replays the request; on refresh failure it fires `SessionExpired`. It **skips** `/auth/login` and `/auth/refresh` so a wrong password never triggers the refresh/logout loop. Endpoints live in `core/constants/api_constants.dart`; the backend wraps responses in `{ data, error: { errorId, errorMsg }, success }` — data sources unwrap this and map `errorId` → typed `Exception`s (`core/error/`), repos map those to `Failure`s, blocs map `Failure`s to localized text. Use `core/network/response_mapper.dart` (`ResponseMapper.asMap` / `.asList` / `.mapDioException`) in every new data source instead of re-implementing envelope unwrapping — some endpoints return the envelope, some return the raw body/list directly, and the mapper handles both.

**Thunder debug overlay**: `app/app.dart` wraps `MaterialApp.router`'s `builder` with `Thunder(dio: [getIt<Dio>()], child: child ?? const SizedBox.shrink())` to inspect network traffic in debug builds (green handle on screen edge, auto-disabled in release via its own `kDebugMode` default). Always pass `child` through — `Thunder` replaces the whole app if `child` is dropped.

### Push notifications (FCM) + WebSocket real-time
Two channels deliver the **same notification shape** — `{id, title, message, type, extra_data, created_at}` (`extra_data.action` is `open_task` | `open_project` for deep-linking). `features/notification/data/models/notification_model.dart` parses both tolerantly.

- **FCM** (`core/services/push_notification_service.dart`, `PushNotificationService`): initialized in `bootstrap()` after `runApp` (non-blocking). Covers all three delivery states — foreground (`onMessage`, shown via `flutter_local_notifications` on the `high_importance_channel`, must match `AndroidManifest`'s `default_notification_channel_id`), background tap (`onMessageOpenedApp`), and terminated tap (`getInitialMessage`). The actual payload is JSON-encoded inside `data['payload']`, not the top-level `data` map — always go through `_payload()`. The top-level background handler (`firebaseMessagingBackgroundHandler`) is a `@pragma('vm:entry-point')` top-level function (isolate re-init requirement).
- **Device registration**: `POST /devices/register/` body is `{fcm_token, device_type: ios|android|web, device_id}` — these are the confirmed Swagger field names (an integration doc that circulated `registration_id`/`type` was wrong; don't reintroduce it). `device_id` is a random hex string generated once and persisted (`StorageKeys.deviceId`).
- **WebSocket** (`features/notification/data/data_sources/notification_socket_service.dart`): `POST /notifications/tickets/` issues a one-time, 60s-lived ticket; connect to `wss://…/ws/notifications/?ticket=<t>`. A fresh ticket is fetched on every (re)connect. Auto-reconnects with linear backoff (2s→30s cap) on error/close. Exposes a broadcast `Stream<NotificationEntity>` consumed by both `NotificationBloc` (prepends to the list) and `bootstrap()` (shows a local notification so in-app users still see it).
- **Lifecycle**: both FCM registration and the WebSocket connection are (re)triggered whenever `SessionBloc` emits `authenticated` (register/ticket endpoints require a Bearer token, which may not exist yet at cold start) and the socket is torn down when the session stops being authenticated. Wired centrally in `bootstrap()` — don't duplicate this elsewhere.

### Auth + PIN + role flow
- First login (`LoginBloc`) stores access+refresh tokens, cached user, **and** the typed login username + password length in storage (`StorageKeys.loginUsername` / `pinLength`).
- PIN re-auth is gated by a **3-minute background timeout** (`SessionBloc.pinLockTimeout`): the lifecycle observer in `app/app.dart` stamps `StorageKeys.lastActiveAt` on background (`SessionBackgrounded`) and re-checks on resume (`SessionResumed`). Bootstrap + resume emit `authenticated` when a token exists and the gap since `lastActiveAt` is ≤ 3 min, else `pinRequired` (cached login) / `unauthenticated` (no cached login). So leaving and returning within 3 min resumes straight to home; longer forces PIN.
- The PIN flow has its own dedicated bloc (`features/auth/presentation/pin/bloc/`). PIN **is** the password: a full PIN fires the login API with the cached username. Indicator slot count is **dynamic** (`pinLength` from storage, never hardcoded). 429 → parse remaining seconds from `errorMsg`, run an in-bloc countdown (`Timer.periodic`), render MM:SS blocked state.
- On auth success `SessionLoggedIn(token, roles)`: 1 role → straight to home; >1 → `roleSelect` (roles listed dynamically from the API response).

### Statistics + charts (fl_chart)
`features/statistics/` follows the same three-layer split, fed by two independent endpoints called in parallel from `StatisticsBloc` (`Future.wait`): `GET /users/me/period-statistics/?months=` (`PeriodStatistics` — projects/tasks/meetings breakdown) and `GET /users/me/efficiency/?months=` (`EfficiencyStatistics` — fetched and stored but **not currently rendered**, no design slot for it yet). The period selector (`StatPeriod` enum: `month1`/`month3`/`month6`/`year1`) maps directly to the `months` query param. Chart widgets (`presentation/widgets/`) are pure — they take an entity and render with `fl_chart`, no bloc access: `tasks_line_chart.dart`, `projects_bar_chart.dart`, `meetings_donut_chart.dart`, wrapped in the shared `ChartCard`. Chart-specific colors are dedicated `AppColors` tokens (`chartLime`/`chartTeal`/`chartNeutral`/`chartGrey`/`chartGreen`/`chartBlue`) — extend that list rather than inlining hex for new chart series.

### Pinned AppBar + pull-to-refresh
Pages needing a sticky header use `CustomScrollView` with a `pinned: true` `SliverAppBar` (see `MainPage`) instead of `Scaffold.appBar` — required when the header must stay fixed over scrolling sliver content. When wrapping such a scroll view in `RefreshIndicator`, set `edgeOffset` to the AppBar's rendered height (`MediaQuery.paddingOf(context).top + toolbarHeight`), otherwise the spinner overlaps the pinned AppBar instead of appearing below it. For simple `Scaffold.appBar` pages (e.g. `NotificationPage`), no `edgeOffset` is needed. Refresh pattern for both: dispatch the reload event, then `await bloc.stream.firstWhere((s) => s.status != Status.loading)` so `RefreshIndicator`'s spinner runs until the request actually completes — don't fake it with a delay. Non-list states (loading/error/empty) must still be wrapped in a scrollable (`AlwaysScrollableScrollPhysics`) or the pull gesture won't register.

## UI rules

- **Widgets:** minimize `Container`. Use `DecoratedBox` + `SizedBox` for styling and spacing/separation.
- **Dimensions:** `flutter_screenutil` is mandatory. Every size, padding, margin, radius, font size uses scaling extensions — `.w`, `.h`, `.r`, `.sp`. No raw logical pixels in layout.
- **Responsiveness:** use `LayoutBuilder` + adaptive constraints for full responsiveness. Always guard text overflow (`maxLines`, `TextOverflow.ellipsis`, `Flexible`/`Expanded`). Components must degrade gracefully across screen sizes.
- **Typography:** style text via the extensions in `lib/core/extentions/text_extensions.dart` — chainable: `'label'.s(16.sp).w(600).c(color)`, plus `.a()` (align) and `.h()` (height). Default typeface is `GoogleFonts.manrope` (already the fallback inside those extensions); enforce Manrope everywhere.
- **Reuse:** prefer existing custom widgets (`lib/core/widgets/`). New shared components must be modular, configurable, and parameterized for multiple call sites — not one-off. Notably: `AppBottomNavBar` (config-driven tab bar, drives the `home` shell's `IndexedStack`) and `TuiAvatar` (avatar circle + read/unread badge drawn with `CustomPainter`, not layered `Stack`/`ClipOval` widgets — follow that pattern for similar badge/indicator graphics instead of nesting positioned widgets).
- **Assets/icons:** reference only via the generated `Assets` class (`core/gen/assets.gen.dart`, flutter_gen) — never hardcode paths or `Icons.*` material glyphs for design icons. Render SVGs with a theme-token `colorFilter` (`Assets.icons.x.svg(colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn))`) so they adapt to light/dark. After adding files under `assets/`, regenerate with `dart run build_runner build --delete-conflicting-outputs`.

## Theme & color

- Dual-mode (light + dark) is required for every UI. Design both at draw time.
- **No raw hex / `Color(0x...)` in page or widget files.** Pull from theme tokens. Two token systems exist (both `ThemeExtension`s):
  - `AppColors` (`config/theme/app_colors.dart`) — current design-system tokens (background/accent/text/stroke/icon/error/success scales). Access: `AppColors.of(context).textStrong`. **Prefer this for new code.**
  - `ThemeColors` (`config/theme/theme_colors.dart`) — older palette, via `context.color` (`build_context_extension.dart`).
- Missing a color? Add a token to the relevant `ThemeExtension` (light + dark + `copyWith` + `lerp`) — never inline it.

## Localization (l10n)

Wired. `l10n.yaml` (template `app_uz.arb`, output `lib/l10n/app_localizations.dart`, `nullable-getter: false`), bundles `lib/l10n/app_uz.arb` (base) + `app_en.arb`. Delegates + `supportedLocales` set in `MaterialApp.router` (`app/app.dart`); app locale forced to `uz`. Access via `AppLocalizations.of(context)`. Generated files (`app_localizations*.dart`) are build output — regenerate with `flutter gen-l10n` after editing `.arb`. Every new/redesigned screen: audit user-facing strings, reuse existing keys, append new keys to **both** `.arb` bundles, then `flutter gen-l10n` — no hardcoded display strings. Blocs stay context-free: emit error/enum types, map to localized text in the widget layer.

## Backend contract discovery

The OpenAPI schema is not linked from `/api/docs/` the obvious way — it's served at `/api/docs/schema/` (YAML), not `/api/schema/` (404s). When a field name or endpoint shape is unclear, fetch that schema and grep the relevant `paths`/`components.schemas` entries rather than guessing from the design or a hand-written integration doc. Hand-written docs and the live schema **have disagreed before** (device-registration field names) — the schema is the source of truth when they conflict. Where the real contract genuinely can't be confirmed, parse tolerantly (see `NotificationModel.fromJson` trying multiple candidate keys) and leave a comment naming the assumption, rather than blocking on it.

## Git workflow

Three-branch strategy (see `CONTRIBUTING.md`): `dev` is the protected default trunk — all work enters via PR. Branch off `dev` as `feature/<desc>` or `bugfix/<desc>`. PR base `dev`, link issue with `Closes #N`. Promote `dev` → `prod` / `main` by PR. Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`).
