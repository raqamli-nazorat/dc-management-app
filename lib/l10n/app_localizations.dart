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

  /// No description provided for @commonOpenFile.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochish'**
  String get commonOpenFile;

  /// No description provided for @commonDownloadFile.
  ///
  /// In uz, this message translates to:
  /// **'Faylni yuklab olish'**
  String get commonDownloadFile;

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

  /// No description provided for @navTasks.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get navTasks;

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

  /// No description provided for @reportEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim bo\'yicha'**
  String get reportEmployee;

  /// No description provided for @reportProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha bo\'yicha'**
  String get reportProject;

  /// No description provided for @reportSpendingRequests.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovlari bo\'yicha'**
  String get reportSpendingRequests;

  /// No description provided for @reportWages.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi bo\'yicha'**
  String get reportWages;

  /// No description provided for @reportTasks.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar bo\'yicha'**
  String get reportTasks;

  /// No description provided for @expenseReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha xarajat so\'rovlari yo\'q'**
  String get expenseReportsEmpty;

  /// No description provided for @expenseReportUncategorized.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi'**
  String get expenseReportUncategorized;

  /// No description provided for @expenseReportAmount.
  ///
  /// In uz, this message translates to:
  /// **'Miqdori (UZS)'**
  String get expenseReportAmount;

  /// No description provided for @expenseReportUser.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get expenseReportUser;

  /// No description provided for @expenseReportAccountant.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchi'**
  String get expenseReportAccountant;

  /// No description provided for @expenseReportProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha'**
  String get expenseReportProject;

  /// No description provided for @expenseReportCategory.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat toifasi'**
  String get expenseReportCategory;

  /// No description provided for @expenseReportType.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat turi'**
  String get expenseReportType;

  /// No description provided for @expenseReportPaymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov turi'**
  String get expenseReportPaymentMethod;

  /// No description provided for @expenseReportPaymentCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd pul'**
  String get expenseReportPaymentCash;

  /// No description provided for @expenseReportPaymentCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqam orqali'**
  String get expenseReportPaymentCard;

  /// No description provided for @expenseReportCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get expenseReportCard;

  /// No description provided for @expenseReportCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Yaratilgan vaqti'**
  String get expenseReportCreatedAt;

  /// No description provided for @expenseReportPaidAt.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan vaqti'**
  String get expenseReportPaidAt;

  /// No description provided for @expenseReportConfirmedAt.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan vaqti'**
  String get expenseReportConfirmedAt;

  /// No description provided for @expenseReportCancelledAt.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan vaqti'**
  String get expenseReportCancelledAt;

  /// No description provided for @expenseReportReason.
  ///
  /// In uz, this message translates to:
  /// **'So\'rov sababi'**
  String get expenseReportReason;

  /// No description provided for @expenseReportCancelReason.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish sababi'**
  String get expenseReportCancelReason;

  /// No description provided for @expenseReportStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get expenseReportStatusPending;

  /// No description provided for @expenseReportStatusPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get expenseReportStatusPaid;

  /// No description provided for @expenseReportStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlandi'**
  String get expenseReportStatusConfirmed;

  /// No description provided for @expenseReportStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilindi'**
  String get expenseReportStatusCancelled;

  /// No description provided for @expenseReportTypeWithdrawal.
  ///
  /// In uz, this message translates to:
  /// **'Mablag\' chiqarish'**
  String get expenseReportTypeWithdrawal;

  /// No description provided for @expenseReportTypeCompany.
  ///
  /// In uz, this message translates to:
  /// **'Kompaniya xarajatlari'**
  String get expenseReportTypeCompany;

  /// No description provided for @expenseReportTypeOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa xarajatlar'**
  String get expenseReportTypeOther;

  /// No description provided for @expenseReportSelect.
  ///
  /// In uz, this message translates to:
  /// **'Tanlang'**
  String get expenseReportSelect;

  /// No description provided for @expenseReportAccountantHint.
  ///
  /// In uz, this message translates to:
  /// **'Hisobchilar tanlang'**
  String get expenseReportAccountantHint;

  /// No description provided for @expenseReportProjectHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tanlang'**
  String get expenseReportProjectHint;

  /// No description provided for @expenseReportTitle.
  ///
  /// In uz, this message translates to:
  /// **'Titul'**
  String get expenseReportTitle;

  /// No description provided for @expenseReportTitleHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi bo\'yicha qidirish'**
  String get expenseReportTitleHint;

  /// No description provided for @taskReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha vazifalar yo\'q'**
  String get taskReportsEmpty;

  /// No description provided for @payrollReportsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha ish haqi hisobotlari yo\'q'**
  String get payrollReportsEmpty;

  /// No description provided for @payrollFixedSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS)'**
  String get payrollFixedSalary;

  /// No description provided for @payrollKpiBonus.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonusi (UZS)'**
  String get payrollKpiBonus;

  /// No description provided for @payrollPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori (UZS)'**
  String get payrollPenalty;

  /// No description provided for @payrollTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami miqdori (UZS)'**
  String get payrollTotal;

  /// No description provided for @payrollCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblangan vaqti'**
  String get payrollCreatedAt;

  /// No description provided for @payrollMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oy uchun'**
  String get payrollMonth;

  /// No description provided for @payrollStatusCalculated.
  ///
  /// In uz, this message translates to:
  /// **'Hisoblangan'**
  String get payrollStatusCalculated;

  /// No description provided for @payrollStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get payrollStatusConfirmed;

  /// No description provided for @taskReportAssignees.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchilar'**
  String get taskReportAssignees;

  /// No description provided for @taskReportAssigneesHint.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchilar tanlang'**
  String get taskReportAssigneesHint;

  /// No description provided for @taskReportSprint.
  ///
  /// In uz, this message translates to:
  /// **'Sprint raqami'**
  String get taskReportSprint;

  /// No description provided for @taskReportPrice.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa narxi (UZS)'**
  String get taskReportPrice;

  /// No description provided for @taskReportPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizi (%)'**
  String get taskReportPenalty;

  /// No description provided for @taskReportReopened.
  ///
  /// In uz, this message translates to:
  /// **'Qaytishlar soni'**
  String get taskReportReopened;

  /// No description provided for @reportsEmployeeEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha xodimlar yo\'q'**
  String get reportsEmployeeEmpty;

  /// No description provided for @reportFixedSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS):'**
  String get reportFixedSalary;

  /// No description provided for @reportBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi (UZS):'**
  String get reportBalance;

  /// No description provided for @reportProjects.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get reportProjects;

  /// No description provided for @reportCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatilgan'**
  String get reportCompleted;

  /// No description provided for @reportTasksCount.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get reportTasksCount;

  /// No description provided for @reportTodo.
  ///
  /// In uz, this message translates to:
  /// **'Qilish kerak'**
  String get reportTodo;

  /// No description provided for @reportMeetings.
  ///
  /// In uz, this message translates to:
  /// **'Yig\'ilishlar'**
  String get reportMeetings;

  /// No description provided for @reportExpenseRequests.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi (UZS):'**
  String get reportExpenseRequests;

  /// No description provided for @reportPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'landi'**
  String get reportPaid;

  /// No description provided for @reportPayroll.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi (UZS):'**
  String get reportPayroll;

  /// No description provided for @reportKpiBonus.
  ///
  /// In uz, this message translates to:
  /// **'KPI bonisi'**
  String get reportKpiBonus;

  /// No description provided for @reportFilterDateRange.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get reportFilterDateRange;

  /// No description provided for @reportFilterPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi'**
  String get reportFilterPosition;

  /// No description provided for @reportFilterPositionHint.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim tanlang'**
  String get reportFilterPositionHint;

  /// No description provided for @reportFilterRegion.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat'**
  String get reportFilterRegion;

  /// No description provided for @reportFilterRegionHint.
  ///
  /// In uz, this message translates to:
  /// **'Viloyat tanlang'**
  String get reportFilterRegionHint;

  /// No description provided for @reportFilterEmployees.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get reportFilterEmployees;

  /// No description provided for @reportFilterEmployeesHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar tanlang'**
  String get reportFilterEmployeesHint;

  /// No description provided for @reportFilterSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi (UZS)'**
  String get reportFilterSalary;

  /// No description provided for @reportFilterBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi (UZS)'**
  String get reportFilterBalance;

  /// No description provided for @reportFilterExpense.
  ///
  /// In uz, this message translates to:
  /// **'Xarajat so\'rovi (UZS)'**
  String get reportFilterExpense;

  /// No description provided for @reportFilterPayroll.
  ///
  /// In uz, this message translates to:
  /// **'Ish haqi (UZS)'**
  String get reportFilterPayroll;

  /// No description provided for @reportFilterFrom.
  ///
  /// In uz, this message translates to:
  /// **'dan'**
  String get reportFilterFrom;

  /// No description provided for @reportFilterTo.
  ///
  /// In uz, this message translates to:
  /// **'gacha'**
  String get reportFilterTo;

  /// No description provided for @reportFilterStatusAll.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get reportFilterStatusAll;

  /// No description provided for @reportFilterGenerate.
  ///
  /// In uz, this message translates to:
  /// **'Shakllantirish'**
  String get reportFilterGenerate;

  /// No description provided for @reportExpenseStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get reportExpenseStatusPending;

  /// No description provided for @reportExpenseStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get reportExpenseStatusConfirmed;

  /// No description provided for @reportExpenseStatusPaidUnconfirmed.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan (tasdiqlanmagan)'**
  String get reportExpenseStatusPaidUnconfirmed;

  /// No description provided for @reportPayrollTypePenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima miqdori'**
  String get reportPayrollTypePenalty;

  /// No description provided for @reportsProjectEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha loyihalar yo\'q'**
  String get reportsProjectEmpty;

  /// No description provided for @reportAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallif:'**
  String get reportAuthor;

  /// No description provided for @reportManager.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi:'**
  String get reportManager;

  /// No description provided for @reportEmployeesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar:'**
  String get reportEmployeesLabel;

  /// No description provided for @reportTestersLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar:'**
  String get reportTestersLabel;

  /// No description provided for @reportManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi bonusi (UZS):'**
  String get reportManagerBonus;

  /// No description provided for @reportStatusLabel.
  ///
  /// In uz, this message translates to:
  /// **'Holati:'**
  String get reportStatusLabel;

  /// No description provided for @reportFilterManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi bonusi'**
  String get reportFilterManagerBonus;

  /// No description provided for @reportFilterAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallifi'**
  String get reportFilterAuthor;

  /// No description provided for @reportFilterAuthorHint.
  ///
  /// In uz, this message translates to:
  /// **'Muallifi tanlang'**
  String get reportFilterAuthorHint;

  /// No description provided for @reportFilterManager.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi'**
  String get reportFilterManager;

  /// No description provided for @reportFilterManagerHint.
  ///
  /// In uz, this message translates to:
  /// **'Boshqaruvchi tanlang'**
  String get reportFilterManagerHint;

  /// No description provided for @reportFilterTesters.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar'**
  String get reportFilterTesters;

  /// No description provided for @reportFilterTestersHint.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar tanlang'**
  String get reportFilterTestersHint;

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

  /// No description provided for @tasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get tasksTitle;

  /// No description provided for @taskAdd.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shish'**
  String get taskAdd;

  /// No description provided for @tasksEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha vazifalar yo‘q'**
  String get tasksEmpty;

  /// No description provided for @taskPriorityLow.
  ///
  /// In uz, this message translates to:
  /// **'Past'**
  String get taskPriorityLow;

  /// No description provided for @taskPriorityMedium.
  ///
  /// In uz, this message translates to:
  /// **'O‘rta'**
  String get taskPriorityMedium;

  /// No description provided for @taskPriorityHigh.
  ///
  /// In uz, this message translates to:
  /// **'Yuqori'**
  String get taskPriorityHigh;

  /// No description provided for @taskPriorityCritical.
  ///
  /// In uz, this message translates to:
  /// **'Kritik'**
  String get taskPriorityCritical;

  /// No description provided for @taskCreateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shish'**
  String get taskCreateTitle;

  /// No description provided for @taskCreateFieldProject.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha'**
  String get taskCreateFieldProject;

  /// No description provided for @taskCreateProjectHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tanlang'**
  String get taskCreateProjectHint;

  /// No description provided for @taskCreateFieldName.
  ///
  /// In uz, this message translates to:
  /// **'Nomi'**
  String get taskCreateFieldName;

  /// No description provided for @taskCreateNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi kiriting'**
  String get taskCreateNameHint;

  /// No description provided for @taskCreateFieldDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsifi'**
  String get taskCreateFieldDescription;

  /// No description provided for @taskCreateDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Tavsifini yozing'**
  String get taskCreateDescriptionHint;

  /// No description provided for @taskCreateFieldPriority.
  ///
  /// In uz, this message translates to:
  /// **'Darajasi'**
  String get taskCreateFieldPriority;

  /// No description provided for @taskCreatePriorityHint.
  ///
  /// In uz, this message translates to:
  /// **'Darajasi tanlang'**
  String get taskCreatePriorityHint;

  /// No description provided for @taskCreateFieldType.
  ///
  /// In uz, this message translates to:
  /// **'Turi'**
  String get taskCreateFieldType;

  /// No description provided for @taskCreateTypeHint.
  ///
  /// In uz, this message translates to:
  /// **'Turini tanlang'**
  String get taskCreateTypeHint;

  /// No description provided for @taskTypeBug.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik (Bug)'**
  String get taskTypeBug;

  /// No description provided for @taskTypeFeature.
  ///
  /// In uz, this message translates to:
  /// **'Yangi funksiya'**
  String get taskTypeFeature;

  /// No description provided for @taskTypeAddition.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha'**
  String get taskTypeAddition;

  /// No description provided for @taskTypeResearch.
  ///
  /// In uz, this message translates to:
  /// **'Tadqiqot/O‘rganish'**
  String get taskTypeResearch;

  /// No description provided for @taskCreateFieldAssigner.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchi'**
  String get taskCreateFieldAssigner;

  /// No description provided for @taskCreateSelectProjectFirst.
  ///
  /// In uz, this message translates to:
  /// **'Avval loyihani tanlang'**
  String get taskCreateSelectProjectFirst;

  /// No description provided for @taskCreateFieldPositions.
  ///
  /// In uz, this message translates to:
  /// **'Kimlar uchun'**
  String get taskCreateFieldPositions;

  /// No description provided for @taskCreatePositionsHint.
  ///
  /// In uz, this message translates to:
  /// **'Tanlang'**
  String get taskCreatePositionsHint;

  /// No description provided for @taskCreateFieldSprint.
  ///
  /// In uz, this message translates to:
  /// **'Sprint'**
  String get taskCreateFieldSprint;

  /// No description provided for @taskCreateFieldPrice.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa narxi (UZS)'**
  String get taskCreateFieldPrice;

  /// No description provided for @taskCreatePriceHint.
  ///
  /// In uz, this message translates to:
  /// **'0,00'**
  String get taskCreatePriceHint;

  /// No description provided for @taskCreateFieldPenalty.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizi (%)'**
  String get taskCreateFieldPenalty;

  /// No description provided for @taskCreatePenaltyHint.
  ///
  /// In uz, this message translates to:
  /// **'Jarima'**
  String get taskCreatePenaltyHint;

  /// No description provided for @taskCreateFieldDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddati'**
  String get taskCreateFieldDeadline;

  /// No description provided for @taskCreateFieldTime.
  ///
  /// In uz, this message translates to:
  /// **'Vaqti'**
  String get taskCreateFieldTime;

  /// No description provided for @taskCreateFieldEstimated.
  ///
  /// In uz, this message translates to:
  /// **'Taxminiy vaqt'**
  String get taskCreateFieldEstimated;

  /// No description provided for @taskCreateFieldFiles.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shimcha fayllar'**
  String get taskCreateFieldFiles;

  /// No description provided for @taskCreateFileUpload.
  ///
  /// In uz, this message translates to:
  /// **'Fayl yuklash'**
  String get taskCreateFileUpload;

  /// No description provided for @taskCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha, nomi va muddat majburiy'**
  String get taskCreateRequiredError;

  /// No description provided for @taskDeadlineChangeRequired.
  ///
  /// In uz, this message translates to:
  /// **'Muddatni o‘zgartiring'**
  String get taskDeadlineChangeRequired;

  /// No description provided for @taskCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa qo‘shildi'**
  String get taskCreateSuccess;

  /// No description provided for @taskEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani tahrirlash'**
  String get taskEditTitle;

  /// No description provided for @taskEditSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get taskEditSave;

  /// No description provided for @taskUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa yangilandi'**
  String get taskUpdateSuccess;

  /// No description provided for @taskDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get taskDetailTitle;

  /// No description provided for @taskDetailCreatedBy.
  ///
  /// In uz, this message translates to:
  /// **'Topshiruvchi'**
  String get taskDetailCreatedBy;

  /// No description provided for @taskDetailRejectReason.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilish sababi'**
  String get taskDetailRejectReason;

  /// No description provided for @taskActionChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirildi'**
  String get taskActionChecked;

  /// No description provided for @taskActionRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get taskActionRejected;

  /// No description provided for @taskActionInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonga o‘tkazish'**
  String get taskActionInProgress;

  /// No description provided for @taskActionMarkDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilganga o‘tkazish'**
  String get taskActionMarkDone;

  /// No description provided for @taskActionProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushurildi'**
  String get taskActionProduction;

  /// No description provided for @taskActionEditDeadline.
  ///
  /// In uz, this message translates to:
  /// **'Muddatni o‘zgartirish'**
  String get taskActionEditDeadline;

  /// No description provided for @taskRejectTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani rad etish'**
  String get taskRejectTitle;

  /// No description provided for @taskRejectSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish sababini kiriting'**
  String get taskRejectSubtitle;

  /// No description provided for @taskRejectHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababini yozing...'**
  String get taskRejectHint;

  /// No description provided for @taskRejectConfirm.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get taskRejectConfirm;

  /// No description provided for @taskStatusUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Holat yangilandi'**
  String get taskStatusUpdated;

  /// No description provided for @meetingEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni tahrirlash'**
  String get meetingEditTitle;

  /// No description provided for @meetingDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish tafsilotlari'**
  String get meetingDetailTitle;

  /// No description provided for @meetingDetailParticipantsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qatnashchilari'**
  String get meetingDetailParticipantsLabel;

  /// No description provided for @meetingUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish yangilandi'**
  String get meetingUpdateSuccess;

  /// No description provided for @meetingCloseAction.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni yakunlash'**
  String get meetingCloseAction;

  /// No description provided for @meetingCloseSheetTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish ishtirokchilarini belgilang'**
  String get meetingCloseSheetTitle;

  /// No description provided for @meetingCloseSheetSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashgan xodimlarni tanlang'**
  String get meetingCloseSheetSubtitle;

  /// No description provided for @meetingCloseConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get meetingCloseConfirm;

  /// No description provided for @meetingCloseSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish yakunlandi'**
  String get meetingCloseSuccess;

  /// No description provided for @meetingExcuseListTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashmaganlar sabablari'**
  String get meetingExcuseListTitle;

  /// No description provided for @meetingExcuseNoReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab hali yozilmagan'**
  String get meetingExcuseNoReason;

  /// No description provided for @meetingExcuseAccepted.
  ///
  /// In uz, this message translates to:
  /// **'Sabab qabul qilindi'**
  String get meetingExcuseAccepted;

  /// No description provided for @meetingExcuseReject.
  ///
  /// In uz, this message translates to:
  /// **'Rad etish'**
  String get meetingExcuseReject;

  /// No description provided for @meetingExcuseRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etildi'**
  String get meetingExcuseRejected;

  /// No description provided for @meetingMyAttended.
  ///
  /// In uz, this message translates to:
  /// **'Siz yig‘ilishda qatnashgansiz'**
  String get meetingMyAttended;

  /// No description provided for @meetingMyNotAttended.
  ///
  /// In uz, this message translates to:
  /// **'Siz yig‘ilishda qatnashmagansiz'**
  String get meetingMyNotAttended;

  /// No description provided for @meetingSendReason.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborish'**
  String get meetingSendReason;

  /// No description provided for @meetingReasonSentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborilgan'**
  String get meetingReasonSentLabel;

  /// No description provided for @meetingDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishni o‘chirish'**
  String get meetingDeleteTitle;

  /// No description provided for @meetingDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.'**
  String get meetingDeleteSubtitle;

  /// No description provided for @projectCreateFilesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha hujjatlari'**
  String get projectCreateFilesLabel;

  /// No description provided for @projectExistingFilesLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud hujjatlar'**
  String get projectExistingFilesLabel;

  /// No description provided for @projectCreateDocsFailed.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha yaratildi, lekin ba\'zi hujjatlar qo‘shilmadi'**
  String get projectCreateDocsFailed;

  /// No description provided for @projectUpdateDocsFailed.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha saqlandi, lekin ba\'zi hujjatlar qo‘shilmadi'**
  String get projectUpdateDocsFailed;

  /// No description provided for @projectDocumentNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomini kiriting'**
  String get projectDocumentNameHint;

  /// No description provided for @projectDocumentLinkHint.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi'**
  String get projectDocumentLinkHint;

  /// No description provided for @projectDocumentAddButton.
  ///
  /// In uz, this message translates to:
  /// **'Hujjat qo‘shish'**
  String get projectDocumentAddButton;

  /// No description provided for @projectDocumentLinkCopied.
  ///
  /// In uz, this message translates to:
  /// **'Havola nusxalandi'**
  String get projectDocumentLinkCopied;

  /// No description provided for @taskMenuDetails.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get taskMenuDetails;

  /// No description provided for @taskMenuDelete.
  ///
  /// In uz, this message translates to:
  /// **'O‘chirish'**
  String get taskMenuDelete;

  /// No description provided for @taskDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifani o‘chirish'**
  String get taskDeleteTitle;

  /// No description provided for @taskDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.'**
  String get taskDeleteSubtitle;

  /// No description provided for @taskDeleteCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get taskDeleteCancel;

  /// No description provided for @taskFilterTitle.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlash'**
  String get taskFilterTitle;

  /// No description provided for @taskFilterStatus.
  ///
  /// In uz, this message translates to:
  /// **'Holati'**
  String get taskFilterStatus;

  /// No description provided for @taskFilterStatusHint.
  ///
  /// In uz, this message translates to:
  /// **'Holati tanlang'**
  String get taskFilterStatusHint;

  /// No description provided for @taskStatusTodo.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilishi kerak'**
  String get taskStatusTodo;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get taskStatusInProgress;

  /// No description provided for @taskStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get taskStatusOverdue;

  /// No description provided for @taskStatusDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get taskStatusDone;

  /// No description provided for @taskStatusProduction.
  ///
  /// In uz, this message translates to:
  /// **'Ishga tushirilgan'**
  String get taskStatusProduction;

  /// No description provided for @taskStatusChecked.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilgan'**
  String get taskStatusChecked;

  /// No description provided for @taskStatusRejected.
  ///
  /// In uz, this message translates to:
  /// **'Rad etilgan'**
  String get taskStatusRejected;

  /// No description provided for @taskFilterAuthor.
  ///
  /// In uz, this message translates to:
  /// **'Muallif'**
  String get taskFilterAuthor;

  /// No description provided for @taskFilterAuthorHint.
  ///
  /// In uz, this message translates to:
  /// **'Muallif tanlang'**
  String get taskFilterAuthorHint;

  /// No description provided for @taskFilterEmployee.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get taskFilterEmployee;

  /// No description provided for @taskFilterEmployeeHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim tanlang'**
  String get taskFilterEmployeeHint;

  /// No description provided for @taskFilterDeadlineRange.
  ///
  /// In uz, this message translates to:
  /// **'Muddat oralig‘i'**
  String get taskFilterDeadlineRange;

  /// No description provided for @taskFilterDateHint.
  ///
  /// In uz, this message translates to:
  /// **'Sana'**
  String get taskFilterDateHint;

  /// No description provided for @taskFilterReset.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get taskFilterReset;

  /// No description provided for @taskFilterApply.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get taskFilterApply;

  /// No description provided for @taskSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Izlash'**
  String get taskSearchHint;

  /// No description provided for @taskSearchClose.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get taskSearchClose;

  /// No description provided for @taskFilterSelectAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘shish'**
  String get taskFilterSelectAdd;

  /// No description provided for @taskFilterSelectedCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta tanlangan'**
  String taskFilterSelectedCount(int count);

  /// No description provided for @projectsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihalar'**
  String get projectsTitle;

  /// No description provided for @projectAdd.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha qo‘shish'**
  String get projectAdd;

  /// No description provided for @projectsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha loyihalar yo‘q'**
  String get projectsEmpty;

  /// No description provided for @projectSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha izlash'**
  String get projectSearchHint;

  /// No description provided for @projectFilterManager.
  ///
  /// In uz, this message translates to:
  /// **'Menejer'**
  String get projectFilterManager;

  /// No description provided for @projectFilterManagerHint.
  ///
  /// In uz, this message translates to:
  /// **'Menejer tanlang'**
  String get projectFilterManagerHint;

  /// No description provided for @projectFilterTitleField.
  ///
  /// In uz, this message translates to:
  /// **'Titul'**
  String get projectFilterTitleField;

  /// No description provided for @projectFilterTitleHint.
  ///
  /// In uz, this message translates to:
  /// **'Titul bo‘yicha izlash'**
  String get projectFilterTitleHint;

  /// No description provided for @projectCreateDefaultPrefix.
  ///
  /// In uz, this message translates to:
  /// **'ERAF'**
  String get projectCreateDefaultPrefix;

  /// No description provided for @projectCreateDefaultPenalty.
  ///
  /// In uz, this message translates to:
  /// **'20'**
  String get projectCreateDefaultPenalty;

  /// No description provided for @projectCreateManagerBonus.
  ///
  /// In uz, this message translates to:
  /// **'Menejer bonusi'**
  String get projectCreateManagerBonus;

  /// No description provided for @projectCreateManagerBonusHint.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha uchun: 0,0'**
  String get projectCreateManagerBonusHint;

  /// No description provided for @projectCreatePrefixHint.
  ///
  /// In uz, this message translates to:
  /// **'Titul kiriting'**
  String get projectCreatePrefixHint;

  /// No description provided for @projectCreateEmployees.
  ///
  /// In uz, this message translates to:
  /// **'Xodimlar'**
  String get projectCreateEmployees;

  /// No description provided for @projectCreateEmployeesHint.
  ///
  /// In uz, this message translates to:
  /// **'Xodim tanlang'**
  String get projectCreateEmployeesHint;

  /// No description provided for @projectUpdateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha yangilandi'**
  String get projectUpdateSuccess;

  /// No description provided for @projectDetailsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha tafsilotlari'**
  String get projectDetailsTitle;

  /// No description provided for @projectEditTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani tahrirlash'**
  String get projectEditTitle;

  /// No description provided for @projectMenuEdit.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get projectMenuEdit;

  /// No description provided for @projectMenuDetails.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get projectMenuDetails;

  /// No description provided for @projectMenuDelete.
  ///
  /// In uz, this message translates to:
  /// **'O\'chirish'**
  String get projectMenuDelete;

  /// No description provided for @projectDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani o\'chirish'**
  String get projectDeleteTitle;

  /// No description provided for @projectDeleteSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Loyihani rostdan ham o\'chirmoqchimisiz? O\'chirilgan loyihani chiqindi qutisidan tiklashingiz mumkin.'**
  String get projectDeleteSubtitle;

  /// No description provided for @projectDeleteCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get projectDeleteCancel;

  /// No description provided for @projectCreateTesters.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchilar'**
  String get projectCreateTesters;

  /// No description provided for @projectCreateTestersHint.
  ///
  /// In uz, this message translates to:
  /// **'Sinovchi tanlang'**
  String get projectCreateTestersHint;

  /// No description provided for @projectCreateActive.
  ///
  /// In uz, this message translates to:
  /// **'Faolmi?'**
  String get projectCreateActive;

  /// No description provided for @projectCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Nomi, titul, menejer va muddat majburiy'**
  String get projectCreateRequiredError;

  /// No description provided for @projectCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha qo‘shildi'**
  String get projectCreateSuccess;

  /// No description provided for @projectStatusPlanning.
  ///
  /// In uz, this message translates to:
  /// **'Rejalashtirilmoqda'**
  String get projectStatusPlanning;

  /// No description provided for @projectStatusActive.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get projectStatusActive;

  /// No description provided for @projectStatusOverdue.
  ///
  /// In uz, this message translates to:
  /// **'Muddati o‘tgan'**
  String get projectStatusOverdue;

  /// No description provided for @projectStatusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan'**
  String get projectStatusCompleted;

  /// No description provided for @projectStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get projectStatusCancelled;

  /// No description provided for @meetingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishlar'**
  String get meetingsTitle;

  /// No description provided for @meetingAdd.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qo‘shish'**
  String get meetingAdd;

  /// No description provided for @meetingsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yig‘ilishlar yo‘q'**
  String get meetingsEmpty;

  /// No description provided for @meetingFilterOrganizer.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchi'**
  String get meetingFilterOrganizer;

  /// No description provided for @meetingFilterOrganizerHint.
  ///
  /// In uz, this message translates to:
  /// **'Tashkilotchini tanlang'**
  String get meetingFilterOrganizerHint;

  /// No description provided for @meetingFilterStartDateRange.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanish sanasi oralig‘i'**
  String get meetingFilterStartDateRange;

  /// No description provided for @meetingCreateNameHint.
  ///
  /// In uz, this message translates to:
  /// **'Nomi yozing'**
  String get meetingCreateNameHint;

  /// No description provided for @meetingCreatePenaltyHint.
  ///
  /// In uz, this message translates to:
  /// **'Jarima foizini kiriting'**
  String get meetingCreatePenaltyHint;

  /// No description provided for @meetingCreateLink.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi'**
  String get meetingCreateLink;

  /// No description provided for @meetingCreateLinkHint.
  ///
  /// In uz, this message translates to:
  /// **'Havolasi kiriting: URL manzil'**
  String get meetingCreateLinkHint;

  /// No description provided for @meetingCreateDescriptionHint.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif yozing'**
  String get meetingCreateDescriptionHint;

  /// No description provided for @meetingCreateStartDate.
  ///
  /// In uz, this message translates to:
  /// **'Muddat sanasi'**
  String get meetingCreateStartDate;

  /// No description provided for @meetingCreateDuration.
  ///
  /// In uz, this message translates to:
  /// **'Davomiyligi'**
  String get meetingCreateDuration;

  /// No description provided for @meetingCreateDurationHint.
  ///
  /// In uz, this message translates to:
  /// **'Daqiqa'**
  String get meetingCreateDurationHint;

  /// No description provided for @meetingCreateParticipantsLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qatnashchilarini qo‘shish'**
  String get meetingCreateParticipantsLabel;

  /// No description provided for @meetingCreateParticipantsHelp.
  ///
  /// In uz, this message translates to:
  /// **'Quyidagi tugma orqali qidiring va tanlang'**
  String get meetingCreateParticipantsHelp;

  /// No description provided for @meetingCreateParticipantsAdd.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashchilarni qo‘shing'**
  String get meetingCreateParticipantsAdd;

  /// No description provided for @meetingCreateParticipantsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qatnashchilarni qo‘shish'**
  String get meetingCreateParticipantsTitle;

  /// No description provided for @meetingCreateCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Tugatildimi?'**
  String get meetingCreateCompleted;

  /// No description provided for @meetingCreateRequiredError.
  ///
  /// In uz, this message translates to:
  /// **'Loyiha, nomi, havolasi, tavsifi, sana va davomiyligi majburiy'**
  String get meetingCreateRequiredError;

  /// No description provided for @meetingCreateSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilish qo‘shildi'**
  String get meetingCreateSuccess;

  /// No description provided for @meetingReasonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yig‘ilishga qatnashmadingiz'**
  String get meetingReasonTitle;

  /// No description provided for @meetingReasonPrompt.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, qatnashmaganlik sababini kiriting'**
  String get meetingReasonPrompt;

  /// No description provided for @meetingReasonHint.
  ///
  /// In uz, this message translates to:
  /// **'Sababni yozing...'**
  String get meetingReasonHint;

  /// No description provided for @meetingReasonSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get meetingReasonSubmit;

  /// No description provided for @meetingReasonSentTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sabab yuborildi.'**
  String get meetingReasonSentTitle;

  /// No description provided for @profileLogoutTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqmoqchimisiz?'**
  String get profileLogoutTitle;

  /// No description provided for @profileLogoutSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Profilingizdan chiqasiz va qayta kirish uchun tizimga yana login qilishingiz kerak bo‘ladi'**
  String get profileLogoutSubtitle;

  /// No description provided for @profileLogoutBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get profileLogoutBack;

  /// No description provided for @profileLogoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get profileLogoutConfirm;

  /// No description provided for @profileThemeSheetTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dizayn mavzusi'**
  String get profileThemeSheetTitle;

  /// No description provided for @profileThemeSheetSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova qanday ko‘rinishini tanlang.'**
  String get profileThemeSheetSubtitle;

  /// No description provided for @profileThemeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug‘lik rejimi'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong‘i rejim'**
  String get profileThemeDark;

  /// No description provided for @securityChangePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parol o‘zgartirish'**
  String get securityChangePassword;

  /// No description provided for @securityAutoLock.
  ///
  /// In uz, this message translates to:
  /// **'Avtomatik qulflash'**
  String get securityAutoLock;

  /// No description provided for @securityAutoLockValue.
  ///
  /// In uz, this message translates to:
  /// **'3 daqiqa'**
  String get securityAutoLockValue;

  /// No description provided for @changePasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o‘zgartirish'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik uchun joriy parolingizni kiriting va yangi parol o‘rnating.'**
  String get changePasswordSubtitle;

  /// No description provided for @changePasswordOldLabel.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol'**
  String get changePasswordOldLabel;

  /// No description provided for @changePasswordOldHint.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parolni kiriting'**
  String get changePasswordOldHint;

  /// No description provided for @changePasswordNewLabel.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get changePasswordNewLabel;

  /// No description provided for @changePasswordNewHint.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni kiriting'**
  String get changePasswordNewHint;

  /// No description provided for @changePasswordConfirmLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlash'**
  String get changePasswordConfirmLabel;

  /// No description provided for @changePasswordConfirmHint.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parolni qayta kiriting'**
  String get changePasswordConfirmHint;

  /// No description provided for @changePasswordErrorOldWrong.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol noto‘g‘ri'**
  String get changePasswordErrorOldWrong;

  /// No description provided for @changePasswordErrorMismatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get changePasswordErrorMismatch;

  /// No description provided for @changePasswordCancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get changePasswordCancel;

  /// No description provided for @changePasswordSave.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get changePasswordSave;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In uz, this message translates to:
  /// **'Parol muvaffaqiyatli o‘zgartirildi.'**
  String get changePasswordSuccess;

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

  /// No description provided for @usersEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha foydalanuvchilar yo\'q'**
  String get usersEmpty;

  /// No description provided for @userFullNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ism sharifi:'**
  String get userFullNameLabel;

  /// No description provided for @userPositionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi:'**
  String get userPositionLabel;

  /// No description provided for @userRoleLabel.
  ///
  /// In uz, this message translates to:
  /// **'Rol:'**
  String get userRoleLabel;

  /// No description provided for @userSalaryLabel.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maoshi:'**
  String get userSalaryLabel;

  /// No description provided for @userBalanceLabel.
  ///
  /// In uz, this message translates to:
  /// **'Balansi:'**
  String get userBalanceLabel;

  /// No description provided for @usersFilterAllPositions.
  ///
  /// In uz, this message translates to:
  /// **'Barcha lavozimlar'**
  String get usersFilterAllPositions;

  /// No description provided for @usersFilterAllRoles.
  ///
  /// In uz, this message translates to:
  /// **'Barcha rollar'**
  String get usersFilterAllRoles;

  /// No description provided for @usersSortNameAsc.
  ///
  /// In uz, this message translates to:
  /// **'A dan Z gacha'**
  String get usersSortNameAsc;

  /// No description provided for @usersSortNameDesc.
  ///
  /// In uz, this message translates to:
  /// **'Z dan A gacha'**
  String get usersSortNameDesc;

  /// No description provided for @usersSortNewest.
  ///
  /// In uz, this message translates to:
  /// **'Yangi → Eski'**
  String get usersSortNewest;

  /// No description provided for @usersSortOldest.
  ///
  /// In uz, this message translates to:
  /// **'Eski → Yangi'**
  String get usersSortOldest;

  /// No description provided for @userDetailTitle.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchining ma’lumotlari'**
  String get userDetailTitle;

  /// No description provided for @userDetailFullName.
  ///
  /// In uz, this message translates to:
  /// **'Ism Sharifi'**
  String get userDetailFullName;

  /// No description provided for @userDetailCreatedAt.
  ///
  /// In uz, this message translates to:
  /// **'Yaratilgan vaqt'**
  String get userDetailCreatedAt;

  /// No description provided for @userDetailPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get userDetailPhone;

  /// No description provided for @userDetailCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get userDetailCard;

  /// No description provided for @userDetailSalary.
  ///
  /// In uz, this message translates to:
  /// **'Oylik maosh'**
  String get userDetailSalary;

  /// No description provided for @userDetailBalance.
  ///
  /// In uz, this message translates to:
  /// **'Balansi'**
  String get userDetailBalance;

  /// No description provided for @userDetailDistrict.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get userDetailDistrict;

  /// No description provided for @userDetailPassport.
  ///
  /// In uz, this message translates to:
  /// **'Passport ma’lumotlari'**
  String get userDetailPassport;

  /// No description provided for @userDetailPassportImage.
  ///
  /// In uz, this message translates to:
  /// **'Passport rasmi'**
  String get userDetailPassportImage;

  /// No description provided for @userDetailPosition.
  ///
  /// In uz, this message translates to:
  /// **'Lavozimi'**
  String get userDetailPosition;

  /// No description provided for @userDetailRole.
  ///
  /// In uz, this message translates to:
  /// **'Rolli'**
  String get userDetailRole;
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
