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
  String get tasksTitle => 'Vazifalar';

  @override
  String get taskAdd => 'Vazifa qo‘shish';

  @override
  String get tasksEmpty => 'Hozircha vazifalar yo‘q';

  @override
  String get taskPriorityLow => 'Past';

  @override
  String get taskPriorityMedium => 'O‘rta';

  @override
  String get taskPriorityHigh => 'Yuqori';

  @override
  String get taskPriorityCritical => 'Kritik';

  @override
  String get taskCreateTitle => 'Vazifa qo‘shish';

  @override
  String get taskCreateFieldProject => 'Loyiha';

  @override
  String get taskCreateProjectHint => 'Loyiha tanlang';

  @override
  String get taskCreateFieldName => 'Nomi';

  @override
  String get taskCreateNameHint => 'Nomi kiriting';

  @override
  String get taskCreateFieldDescription => 'Tavsifi';

  @override
  String get taskCreateDescriptionHint => 'Tavsifini yozing';

  @override
  String get taskCreateFieldPriority => 'Darajasi';

  @override
  String get taskCreatePriorityHint => 'Darajasi tanlang';

  @override
  String get taskCreateFieldType => 'Turi';

  @override
  String get taskCreateTypeHint => 'Turini tanlang';

  @override
  String get taskTypeBug => 'Xatolik (Bug)';

  @override
  String get taskTypeFeature => 'Yangi funksiya';

  @override
  String get taskTypeAddition => 'Qo‘shimcha';

  @override
  String get taskTypeResearch => 'Tadqiqot/O‘rganish';

  @override
  String get taskCreateFieldAssigner => 'Topshiruvchi';

  @override
  String get taskCreateSelectProjectFirst => 'Avval loyihani tanlang';

  @override
  String get taskCreateFieldPositions => 'Kimlar uchun';

  @override
  String get taskCreatePositionsHint => 'Tanlang';

  @override
  String get taskCreateFieldSprint => 'Sprint';

  @override
  String get taskCreateFieldPrice => 'Vazifa narxi (UZS)';

  @override
  String get taskCreatePriceHint => '0,00';

  @override
  String get taskCreateFieldPenalty => 'Jarima foizi (%)';

  @override
  String get taskCreatePenaltyHint => 'Jarima';

  @override
  String get taskCreateFieldDeadline => 'Muddati';

  @override
  String get taskCreateFieldTime => 'Vaqti';

  @override
  String get taskCreateFieldEstimated => 'Taxminiy vaqt';

  @override
  String get taskCreateFieldFiles => 'Qo‘shimcha fayllar';

  @override
  String get taskCreateFileUpload => 'Fayl yuklash';

  @override
  String get taskCreateRequiredError => 'Loyiha, nomi va muddat majburiy';

  @override
  String get taskCreateSuccess => 'Vazifa qo‘shildi';

  @override
  String get taskMenuDetails => 'Batafsil';

  @override
  String get taskMenuDelete => 'O‘chirish';

  @override
  String get taskDeleteTitle => 'Vazifani o‘chirish';

  @override
  String get taskDeleteSubtitle =>
      'Vazifa chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.';

  @override
  String get taskDeleteCancel => 'Bekor qilish';

  @override
  String get taskFilterTitle => 'Filtrlash';

  @override
  String get taskFilterStatus => 'Holati';

  @override
  String get taskFilterStatusHint => 'Holati tanlang';

  @override
  String get taskStatusTodo => 'Bajarilishi kerak';

  @override
  String get taskStatusInProgress => 'Jarayonda';

  @override
  String get taskStatusOverdue => 'Muddati o‘tgan';

  @override
  String get taskStatusDone => 'Bajarilgan';

  @override
  String get taskStatusProduction => 'Ishga tushirilgan';

  @override
  String get taskStatusChecked => 'Tekshirilgan';

  @override
  String get taskStatusRejected => 'Rad etilgan';

  @override
  String get taskFilterAuthor => 'Muallif';

  @override
  String get taskFilterAuthorHint => 'Muallif tanlang';

  @override
  String get taskFilterEmployee => 'Xodim';

  @override
  String get taskFilterEmployeeHint => 'Xodim tanlang';

  @override
  String get taskFilterDeadlineRange => 'Muddat oralig‘i';

  @override
  String get taskFilterDateHint => 'Sana';

  @override
  String get taskFilterReset => 'Tozalash';

  @override
  String get taskFilterApply => 'Qidirish';

  @override
  String get taskSearchHint => 'Izlash';

  @override
  String get taskSearchClose => 'Yopish';

  @override
  String get taskFilterSelectAdd => 'Qo‘shish';

  @override
  String taskFilterSelectedCount(int count) {
    return '$count ta tanlangan';
  }

  @override
  String get meetingsTitle => 'Yig‘ilishlar';

  @override
  String get meetingAdd => 'Yig‘ilish qo‘shish';

  @override
  String get meetingsEmpty => 'Hozircha yig‘ilishlar yo‘q';

  @override
  String get meetingFilterOrganizer => 'Tashkilotchi';

  @override
  String get meetingFilterOrganizerHint => 'Tashkilotchini tanlang';

  @override
  String get meetingFilterStartDateRange => 'Boshlanish sanasi oralig‘i';

  @override
  String get meetingCreateNameHint => 'Nomi yozing';

  @override
  String get meetingCreatePenaltyHint => 'Jarima foizini kiriting';

  @override
  String get meetingCreateLink => 'Havolasi';

  @override
  String get meetingCreateLinkHint => 'Havolasi kiriting: URL manzil';

  @override
  String get meetingCreateDescriptionHint => 'Tavsif yozing';

  @override
  String get meetingCreateStartDate => 'Muddat sanasi';

  @override
  String get meetingCreateDuration => 'Davomiyligi';

  @override
  String get meetingCreateDurationHint => 'Daqiqa';

  @override
  String get meetingCreateParticipantsLabel =>
      'Yig‘ilish qatnashchilarini qo‘shish';

  @override
  String get meetingCreateParticipantsHelp =>
      'Quyidagi tugma orqali qidiring va tanlang';

  @override
  String get meetingCreateParticipantsAdd => 'Qatnashchilarni qo‘shing';

  @override
  String get meetingCreateParticipantsTitle => 'Qatnashchilarni qo‘shish';

  @override
  String get meetingCreateCompleted => 'Tugatildimi?';

  @override
  String get meetingCreateRequiredError =>
      'Loyiha, nomi, havolasi, tavsifi, sana va davomiyligi majburiy';

  @override
  String get meetingCreateSuccess => 'Yig‘ilish qo‘shildi';

  @override
  String get meetingReasonTitle => 'Yig‘ilishga qatnashmadingiz';

  @override
  String get meetingReasonPrompt =>
      'Iltimos, qatnashmaganlik sababini kiriting';

  @override
  String get meetingReasonHint => 'Sababni yozing...';

  @override
  String get meetingReasonSubmit => 'Yuborish';

  @override
  String get meetingReasonSentTitle => 'Sabab yuborildi.';

  @override
  String get profileLogoutTitle => 'Profilingizdan chiqmoqchimisiz?';

  @override
  String get profileLogoutSubtitle =>
      'Profilingizdan chiqasiz va qayta kirish uchun tizimga yana login qilishingiz kerak bo‘ladi';

  @override
  String get profileLogoutBack => 'Orqaga';

  @override
  String get profileLogoutConfirm => 'Chiqish';

  @override
  String get profileThemeSheetTitle => 'Dizayn mavzusi';

  @override
  String get profileThemeSheetSubtitle => 'Ilova qanday ko‘rinishini tanlang.';

  @override
  String get profileThemeLight => 'Yorug‘lik rejimi';

  @override
  String get profileThemeDark => 'Qorong‘i rejim';

  @override
  String get securityChangePassword => 'Parol o‘zgartirish';

  @override
  String get securityAutoLock => 'Avtomatik qulflash';

  @override
  String get securityAutoLockValue => '3 daqiqa';

  @override
  String get changePasswordTitle => 'Parolni o‘zgartirish';

  @override
  String get changePasswordSubtitle =>
      'Xavfsizlik uchun joriy parolingizni kiriting va yangi parol o‘rnating.';

  @override
  String get changePasswordOldLabel => 'Joriy parol';

  @override
  String get changePasswordOldHint => 'Joriy parolni kiriting';

  @override
  String get changePasswordNewLabel => 'Yangi parol';

  @override
  String get changePasswordNewHint => 'Yangi parolni kiriting';

  @override
  String get changePasswordConfirmLabel => 'Parolni tasdiqlash';

  @override
  String get changePasswordConfirmHint => 'Yangi parolni qayta kiriting';

  @override
  String get changePasswordErrorOldWrong => 'Joriy parol noto‘g‘ri';

  @override
  String get changePasswordErrorMismatch => 'Parollar mos kelmadi';

  @override
  String get changePasswordCancel => 'Bekor qilish';

  @override
  String get changePasswordSave => 'Saqlash';

  @override
  String get changePasswordSuccess => 'Parol muvaffaqiyatli o‘zgartirildi.';

  @override
  String get commonError =>
      'Nimadir xato ketdi. Birozdan so‘ng qayta urinib ko‘ring.';

  @override
  String get networkError => 'Internet aloqasi yo‘q. Ulanishni tekshiring.';
}
