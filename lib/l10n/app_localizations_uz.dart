// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get pinTitle => 'PIN-kodni kiriting';

  @override
  String get pinSubtitle =>
      'Hisobingizga kirishni tasdiqlash uchun PIN-kodni kiriting';

  @override
  String get pinIncorrect => 'PIN-kod noto‘g‘ri';

  @override
  String get pinRetry => 'Iltimos, qayta urinib ko‘ring';

  @override
  String get pinBlocked => 'Kirish vaqtincha bloklandi';

  @override
  String pinBlockedRetryIn(String time) {
    return 'Qayta urinish uchun: $time';
  }

  @override
  String get roleTitle =>
      'Siz dasturni bir nechta rol bilan foydalanishingiz mumkin';

  @override
  String get roleSubtitle => 'Quyidagilardan birini tanlang.';

  @override
  String get roleAdministrator => 'Administrator';

  @override
  String get roleManager => 'Menejer';

  @override
  String get roleAccountant => 'Hisobchi';

  @override
  String get roleSupervisor => 'Nazoratchi';

  @override
  String get roleEmployee => 'Xodim';

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String get notificationsEmpty => 'Hozircha bildirishnomalar yo‘q';

  @override
  String get notificationMarkAllRead => 'Barchasini o‘qilgan deb belgilash';

  @override
  String get notificationClose => 'Yopish';

  @override
  String get comingSoon => 'Tez orada';

  @override
  String get commonRetry => 'Qayta urinish';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navUsers => 'Foydalanuvchilar';

  @override
  String get navProjects => 'Loyihalar';

  @override
  String get navFinance => 'Moliya';

  @override
  String get navReports => 'Hisobotlar';

  @override
  String get statPeriodSelect => 'Davrni tanlang';

  @override
  String get statPeriod1Month => '1 oy';

  @override
  String get statPeriod3Months => '3 oy';

  @override
  String get statPeriod6Months => '6 oy';

  @override
  String get statPeriod1Year => '1 yil';

  @override
  String get statTasksTitle => 'Vazifalar';

  @override
  String get statTaskTodo => 'Qilish kerak';

  @override
  String get statTaskInProgress => 'Jarayonda';

  @override
  String get statTaskDone => 'Bajarilgan';

  @override
  String get statTaskProduction => 'Ishga tushirilgan';

  @override
  String get statTaskChecked => 'Tekshirilgan';

  @override
  String get statTaskRejected => 'Rad etilgan';

  @override
  String get statTaskOverdue => 'Muddati o‘tgan';

  @override
  String get statProjectsTitle => 'Loyihalar';

  @override
  String get statProjectCompleted => 'Tugatilgan';

  @override
  String get statProjectActive => 'Jarayonda';

  @override
  String get statProjectCancelled => 'Bekor';

  @override
  String get statProjectOverdue => 'Muddati';

  @override
  String get statProjectPlanning => 'Rejalashtirilgan';

  @override
  String get statMeetingsTitle => 'Yig‘ilishlar dinamikasi';

  @override
  String get statMeetingAttended => 'Qatnashdi';

  @override
  String get statMeetingExcused => 'Sababli';

  @override
  String get statMeetingUnexcused => 'Sababsiz';

  @override
  String get statEmpty => 'Ma’lumot yo‘q';

  @override
  String profileTitle(String role) {
    return '$role ma’lumotlari';
  }

  @override
  String get profileRoleManage => 'Rol boshqarish';

  @override
  String get profileSecurity => 'Xafsizlik';

  @override
  String get profileTheme => 'Dizayn mavzusi';

  @override
  String get profileAbout => 'Ilova haqida';

  @override
  String profileVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String roleSwitchedTitle(String role) {
    return '$role roliga o‘tildi.';
  }

  @override
  String roleSwitchedSubtitle(String role) {
    return 'Siz endi $role sifatida ishlayapsiz.';
  }

  @override
  String get commonError =>
      'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.';

  @override
  String get networkError => 'Internet aloqasi yo‘q. Ulanishni tekshiring.';
}
