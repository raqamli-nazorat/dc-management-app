import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('uz'),
    Locale('en'),
  ];

  /// No description provided for @pinTitle.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kodni kiriting'**
  String get pinTitle;

  /// No description provided for @pinSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga kirishni tasdiqlash uchun PIN-kodni kiriting'**
  String get pinSubtitle;

  /// No description provided for @pinIncorrect.
  ///
  /// In uz, this message translates to:
  /// **'PIN-kod noto‘g‘ri'**
  String get pinIncorrect;

  /// No description provided for @pinRetry.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, qayta urinib ko‘ring'**
  String get pinRetry;

  /// No description provided for @pinBlocked.
  ///
  /// In uz, this message translates to:
  /// **'Kirish vaqtincha bloklandi'**
  String get pinBlocked;

  /// No description provided for @pinBlockedRetryIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish uchun: {time}'**
  String pinBlockedRetryIn(String time);

  /// No description provided for @roleTitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz dasturni bir nechta rol bilan foydalanishingiz mumkin'**
  String get roleTitle;

  /// No description provided for @roleSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Quyidagilardan birini tanlang.'**
  String get roleSubtitle;

  /// No description provided for @roleAdministrator.
  ///
  /// In uz, this message translates to:
  /// **'Administrator'**
  String get roleAdministrator;

  /// No description provided for @roleManager.
  ///
  /// In uz, this message translates to:
  /// **'Menejer'**
  String get roleManager;

  /// No description provided for @roleAccountant.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchi'**
  String get roleAccountant;

  /// No description provided for @roleSupervisor.
  ///
  /// In uz, this message translates to:
  /// **'Nazoratchi'**
  String get roleSupervisor;

  /// No description provided for @roleEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get roleEmployee;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha bildirishnomalar yo‘q'**
  String get notificationsEmpty;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o‘qilgan deb belgilash'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get notificationClose;

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada'**
  String get comingSoon;

  /// No description provided for @commonRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get commonRetry;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get navHome;

  /// No description provided for @navUsers.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilar'**
  String get navUsers;

  /// No description provided for @navProjects.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get navProjects;

  /// No description provided for @navFinance.
  ///
  /// In uz, this message translates to:
  /// **'Moliya'**
  String get navFinance;

  /// No description provided for @navReports.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotlar'**
  String get navReports;

  /// No description provided for @statPeriodSelect.
  ///
  /// In uz, this message translates to:
  /// **'Davrni tanlang'**
  String get statPeriodSelect;

  /// No description provided for @statPeriod1Month.
  ///
  /// In uz, this message translates to:
  /// **'1 oy'**
  String get statPeriod1Month;

  /// No description provided for @statPeriod3Months.
  ///
  /// In uz, this message translates to:
  /// **'3 oy'**
  String get statPeriod3Months;

  /// No description provided for @statPeriod6Months.
  ///
  /// In uz, this message translates to:
  /// **'6 oy'**
  String get statPeriod6Months;

  /// No description provided for @statPeriod1Year.
  ///
  /// In uz, this message translates to:
  /// **'1 yil'**
  String get statPeriod1Year;

  /// No description provided for @statTasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get statTasksTitle;

  /// No description provided for @statTaskTodo.
  ///
  /// In uz, this message translates to:
  /// **'Qilish kerak'**
  String get statTaskTodo;

  /// No description provided for @statTaskInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statTaskInProgress;

  /// No description provided for @statTaskDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get statTaskDone;

  /// No description provided for @statTaskProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushirilgan'**
  String get statTaskProduction;

  /// No description provided for @statTaskChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilgan'**
  String get statTaskChecked;

  /// No description provided for @statTaskRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get statTaskRejected;

  /// No description provided for @statTaskOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get statTaskOverdue;

  /// No description provided for @statProjectsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get statProjectsTitle;

  /// No description provided for @statProjectCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatilgan'**
  String get statProjectCompleted;

  /// No description provided for @statProjectActive.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statProjectActive;

  /// No description provided for @statProjectCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor'**
  String get statProjectCancelled;

  /// No description provided for @statProjectOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get statProjectOverdue;

  /// No description provided for @statProjectPlanning.
  ///
  /// In uz, this message translates to:
  /// **'Rejalashtirilgan'**
  String get statProjectPlanning;

  /// No description provided for @statMeetingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishlar dinamikasi'**
  String get statMeetingsTitle;

  /// No description provided for @statMeetingAttended.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashdi'**
  String get statMeetingAttended;

  /// No description provided for @statMeetingExcused.
  ///
  /// In uz, this message translates to:
  /// **'Sababli'**
  String get statMeetingExcused;

  /// No description provided for @statMeetingUnexcused.
  ///
  /// In uz, this message translates to:
  /// **'Sababsiz'**
  String get statMeetingUnexcused;

  /// No description provided for @statEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Ma’lumot yo‘q'**
  String get statEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'{role} ma’lumotlari'**
  String profileTitle(String role);

  /// No description provided for @profileRoleManage.
  ///
  /// In uz, this message translates to:
  /// **'Rol boshqarish'**
  String get profileRoleManage;

  /// No description provided for @profileSecurity.
  ///
  /// In uz, this message translates to:
  /// **'Xafsizlik'**
  String get profileSecurity;

  /// No description provided for @profileTheme.
  ///
  /// In uz, this message translates to:
  /// **'Dizayn mavzusi'**
  String get profileTheme;

  /// No description provided for @profileAbout.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get profileAbout;

  /// No description provided for @profileVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {version}'**
  String profileVersion(String version);

  /// No description provided for @roleSwitchedTitle.
  ///
  /// In uz, this message translates to:
  /// **'{role} roliga o‘tildi.'**
  String roleSwitchedTitle(String role);

  /// No description provided for @roleSwitchedSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Siz endi {role} sifatida ishlayapsiz.'**
  String roleSwitchedSubtitle(String role);

  /// No description provided for @commonError.
  ///
  /// In uz, this message translates to:
  /// **'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.'**
  String get commonError;

  /// No description provided for @networkError.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqasi yo‘q. Ulanishni tekshiring.'**
  String get networkError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
