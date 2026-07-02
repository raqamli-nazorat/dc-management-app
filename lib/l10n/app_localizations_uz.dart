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
  String get commonError =>
      'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.';

  @override
  String get networkError => 'Internet aloqasi yo‘q. Ulanishni tekshiring.';
}
