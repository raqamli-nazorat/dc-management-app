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
  String get commonOpenFile => 'Faylni ochish';

  @override
  String get commonDownloadFile => 'Faylni yuklab olish';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navUsers => 'Foydalanuvchilar';

  @override
  String get navTasks => 'Vazifalar';

  @override
  String get navFinance => 'Moliya';

  @override
  String get navReports => 'Hisobotlar';

  @override
  String get reportEmployee => 'Xodim bo\'yicha';

  @override
  String get reportProject => 'Loyiha bo\'yicha';

  @override
  String get reportSpendingRequests => 'Xarajat so\'rovlari bo\'yicha';

  @override
  String get reportWages => 'Ish haqi bo\'yicha';

  @override
  String get reportTasks => 'Vazifalar bo\'yicha';

  @override
  String get expenseReportsEmpty => 'Hozircha xarajat so\'rovlari yo\'q';

  @override
  String get expenseReportUncategorized => 'Xarajat so\'rovi';

  @override
  String get expenseReportAmount => 'Miqdori (UZS)';

  @override
  String get expenseReportUser => 'Xodim';

  @override
  String get expenseReportAccountant => 'Hisobchi';

  @override
  String get expenseReportProject => 'Loyiha';

  @override
  String get expenseReportCategory => 'Xarajat toifasi';

  @override
  String get expenseReportType => 'Xarajat turi';

  @override
  String get expenseReportPaymentMethod => 'To\'lov turi';

  @override
  String get expenseReportPaymentCash => 'Naqd pul';

  @override
  String get expenseReportPaymentCard => 'Karta raqam orqali';

  @override
  String get expenseReportCard => 'Karta raqami';

  @override
  String get expenseReportCreatedAt => 'Yaratilgan vaqti';

  @override
  String get expenseReportPaidAt => 'To\'langan vaqti';

  @override
  String get expenseReportConfirmedAt => 'Tasdiqlangan vaqti';

  @override
  String get expenseReportCancelledAt => 'Bekor qilingan vaqti';

  @override
  String get expenseReportReason => 'So\'rov sababi';

  @override
  String get expenseReportCancelReason => 'Bekor qilish sababi';

  @override
  String get expenseReportStatusPending => 'Kutilmoqda';

  @override
  String get expenseReportStatusPaid => 'To\'landi';

  @override
  String get expenseReportStatusConfirmed => 'Tasdiqlandi';

  @override
  String get expenseReportStatusCancelled => 'Bekor qilindi';

  @override
  String get expenseReportTypeWithdrawal => 'Mablag\' chiqarish';

  @override
  String get expenseReportTypeCompany => 'Kompaniya xarajatlari';

  @override
  String get expenseReportTypeOther => 'Boshqa xarajatlar';

  @override
  String get expenseReportSelect => 'Tanlang';

  @override
  String get expenseReportAccountantHint => 'Hisobchilar tanlang';

  @override
  String get expenseReportProjectHint => 'Loyiha tanlang';

  @override
  String get expenseReportTitle => 'Titul';

  @override
  String get expenseReportTitleHint => 'Nomi bo\'yicha qidirish';

  @override
  String get taskReportsEmpty => 'Hozircha vazifalar yo\'q';

  @override
  String get payrollReportsEmpty => 'Hozircha ish haqi hisobotlari yo\'q';

  @override
  String get payrollFixedSalary => 'Oylik maoshi (UZS)';

  @override
  String get payrollKpiBonus => 'KPI bonusi (UZS)';

  @override
  String get payrollPenalty => 'Jarima miqdori (UZS)';

  @override
  String get payrollTotal => 'Jami miqdori (UZS)';

  @override
  String get payrollCreatedAt => 'Hisoblangan vaqti';

  @override
  String get payrollMonth => 'Oy uchun';

  @override
  String get payrollStatusCalculated => 'Hisoblangan';

  @override
  String get payrollStatusConfirmed => 'Tasdiqlangan';

  @override
  String get taskReportAssignees => 'Topshiruvchilar';

  @override
  String get taskReportAssigneesHint => 'Topshiruvchilar tanlang';

  @override
  String get taskReportSprint => 'Sprint raqami';

  @override
  String get taskReportPrice => 'Vazifa narxi (UZS)';

  @override
  String get taskReportPenalty => 'Jarima foizi (%)';

  @override
  String get taskReportReopened => 'Qaytishlar soni';

  @override
  String get reportsEmployeeEmpty => 'Hozircha xodimlar yo\'q';

  @override
  String get reportFixedSalary => 'Oylik maoshi (UZS):';

  @override
  String get reportBalance => 'Balansi (UZS):';

  @override
  String get reportProjects => 'Loyihalar';

  @override
  String get reportCompleted => 'Tugatilgan';

  @override
  String get reportTasksCount => 'Vazifalar';

  @override
  String get reportTodo => 'Qilish kerak';

  @override
  String get reportMeetings => 'Yig\'ilishlar';

  @override
  String get reportExpenseRequests => 'Xarajat so\'rovi (UZS):';

  @override
  String get reportPaid => 'To\'landi';

  @override
  String get reportPayroll => 'Ish haqi (UZS):';

  @override
  String get reportKpiBonus => 'KPI bonisi';

  @override
  String get reportFilterDateRange => 'Muddati';

  @override
  String get reportFilterPosition => 'Lavozimi';

  @override
  String get reportFilterPositionHint => 'Lavozim tanlang';

  @override
  String get reportFilterRegion => 'Viloyat';

  @override
  String get reportFilterRegionHint => 'Viloyat tanlang';

  @override
  String get reportFilterEmployees => 'Xodimlar';

  @override
  String get reportFilterEmployeesHint => 'Xodimlar tanlang';

  @override
  String get reportFilterSalary => 'Oylik maoshi (UZS)';

  @override
  String get reportFilterBalance => 'Balansi (UZS)';

  @override
  String get reportFilterExpense => 'Xarajat so\'rovi (UZS)';

  @override
  String get reportFilterPayroll => 'Ish haqi (UZS)';

  @override
  String get reportFilterFrom => 'dan';

  @override
  String get reportFilterTo => 'gacha';

  @override
  String get reportFilterStatusAll => 'Jami';

  @override
  String get reportFilterGenerate => 'Shakllantirish';

  @override
  String get reportExpenseStatusPending => 'Kutilmoqda';

  @override
  String get reportExpenseStatusConfirmed => 'To\'langan';

  @override
  String get reportExpenseStatusPaidUnconfirmed =>
      'To\'langan (tasdiqlanmagan)';

  @override
  String get reportPayrollTypePenalty => 'Jarima miqdori';

  @override
  String get reportsProjectEmpty => 'Hozircha loyihalar yo\'q';

  @override
  String get reportAuthor => 'Muallif:';

  @override
  String get reportManager => 'Boshqaruvchi:';

  @override
  String get reportEmployeesLabel => 'Xodimlar:';

  @override
  String get reportTestersLabel => 'Sinovchilar:';

  @override
  String get reportManagerBonus => 'Boshqaruvchi bonusi (UZS):';

  @override
  String get reportStatusLabel => 'Holati:';

  @override
  String get reportFilterManagerBonus => 'Boshqaruvchi bonusi';

  @override
  String get reportFilterAuthor => 'Muallifi';

  @override
  String get reportFilterAuthorHint => 'Muallifi tanlang';

  @override
  String get reportFilterManager => 'Boshqaruvchi';

  @override
  String get reportFilterManagerHint => 'Boshqaruvchi tanlang';

  @override
  String get reportFilterTesters => 'Sinovchilar';

  @override
  String get reportFilterTestersHint => 'Sinovchilar tanlang';

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
  String get taskDeadlineChangeRequired => 'Muddatni o‘zgartiring';

  @override
  String get taskCreateSuccess => 'Vazifa qo‘shildi';

  @override
  String get taskEditTitle => 'Vazifani tahrirlash';

  @override
  String get taskEditSave => 'Saqlash';

  @override
  String get taskUpdateSuccess => 'Vazifa yangilandi';

  @override
  String get taskDetailTitle => 'Batafsil';

  @override
  String get taskDetailCreatedBy => 'Topshiruvchi';

  @override
  String get taskDetailRejectReason => 'Rad etilish sababi';

  @override
  String get taskActionChecked => 'Tekshirildi';

  @override
  String get taskActionRejected => 'Rad etildi';

  @override
  String get taskActionInProgress => 'Jarayonga o‘tkazish';

  @override
  String get taskActionMarkDone => 'Bajarilganga o‘tkazish';

  @override
  String get taskActionProduction => 'Ishga tushurildi';

  @override
  String get taskActionEditDeadline => 'Muddatni o‘zgartirish';

  @override
  String get taskRejectTitle => 'Vazifani rad etish';

  @override
  String get taskRejectSubtitle => 'Rad etish sababini kiriting';

  @override
  String get taskRejectHint => 'Sababini yozing...';

  @override
  String get taskRejectConfirm => 'O‘chirish';

  @override
  String get taskStatusUpdated => 'Holat yangilandi';

  @override
  String get meetingEditTitle => 'Yig‘ilishni tahrirlash';

  @override
  String get meetingDetailTitle => 'Yig‘ilish tafsilotlari';

  @override
  String get meetingDetailParticipantsLabel => 'Yig‘ilish qatnashchilari';

  @override
  String get meetingUpdateSuccess => 'Yig‘ilish yangilandi';

  @override
  String get meetingCloseAction => 'Yig‘ilishni yakunlash';

  @override
  String get meetingCloseSheetTitle => 'Yig‘ilish ishtirokchilarini belgilang';

  @override
  String get meetingCloseSheetSubtitle => 'Qatnashgan xodimlarni tanlang';

  @override
  String get meetingCloseConfirm => 'Tasdiqlash';

  @override
  String get meetingCloseSuccess => 'Yig‘ilish yakunlandi';

  @override
  String get meetingExcuseListTitle => 'Qatnashmaganlar sabablari';

  @override
  String get meetingExcuseNoReason => 'Sabab hali yozilmagan';

  @override
  String get meetingExcuseAccepted => 'Sabab qabul qilindi';

  @override
  String get meetingExcuseReject => 'Rad etish';

  @override
  String get meetingExcuseRejected => 'Rad etildi';

  @override
  String get meetingMyAttended => 'Siz yig‘ilishda qatnashgansiz';

  @override
  String get meetingMyNotAttended => 'Siz yig‘ilishda qatnashmagansiz';

  @override
  String get meetingSendReason => 'Sabab yuborish';

  @override
  String get meetingReasonSentLabel => 'Sabab yuborilgan';

  @override
  String get meetingDeleteTitle => 'Yig‘ilishni o‘chirish';

  @override
  String get meetingDeleteSubtitle =>
      'Yig‘ilish chiqindi qutisiga yuboriladi va keyinchalik tiklash mumkin.';

  @override
  String get projectCreateFilesLabel => 'Loyiha hujjatlari';

  @override
  String get projectExistingFilesLabel => 'Mavjud hujjatlar';

  @override
  String get projectCreateDocsFailed =>
      'Loyiha yaratildi, lekin ba\'zi hujjatlar qo‘shilmadi';

  @override
  String get projectUpdateDocsFailed =>
      'Loyiha saqlandi, lekin ba\'zi hujjatlar qo‘shilmadi';

  @override
  String get projectDocumentNameHint => 'Nomini kiriting';

  @override
  String get projectDocumentLinkHint => 'Havolasi';

  @override
  String get projectDocumentAddButton => 'Hujjat qo‘shish';

  @override
  String get projectDocumentLinkCopied => 'Havola nusxalandi';

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
  String get projectsTitle => 'Loyihalar';

  @override
  String get projectAdd => 'Loyiha qo‘shish';

  @override
  String get projectsEmpty => 'Hozircha loyihalar yo‘q';

  @override
  String get projectSearchHint => 'Loyiha izlash';

  @override
  String get projectFilterManager => 'Menejer';

  @override
  String get projectFilterManagerHint => 'Menejer tanlang';

  @override
  String get projectFilterTitleField => 'Titul';

  @override
  String get projectFilterTitleHint => 'Titul bo‘yicha izlash';

  @override
  String get projectCreateDefaultPrefix => 'ERAF';

  @override
  String get projectCreateDefaultPenalty => '20';

  @override
  String get projectCreateManagerBonus => 'Menejer bonusi';

  @override
  String get projectCreateManagerBonusHint => 'Loyiha uchun: 0,0';

  @override
  String get projectCreatePrefixHint => 'Titul kiriting';

  @override
  String get projectCreateEmployees => 'Xodimlar';

  @override
  String get projectCreateEmployeesHint => 'Xodim tanlang';

  @override
  String get projectUpdateSuccess => 'Loyiha yangilandi';

  @override
  String get projectDetailsTitle => 'Loyiha tafsilotlari';

  @override
  String get projectEditTitle => 'Loyihani tahrirlash';

  @override
  String get projectMenuEdit => 'Tahrirlash';

  @override
  String get projectMenuDetails => 'Batafsil';

  @override
  String get projectMenuDelete => 'O\'chirish';

  @override
  String get projectDeleteTitle => 'Loyihani o\'chirish';

  @override
  String get projectDeleteSubtitle =>
      'Loyihani rostdan ham o\'chirmoqchimisiz? O\'chirilgan loyihani chiqindi qutisidan tiklashingiz mumkin.';

  @override
  String get projectDeleteCancel => 'Bekor qilish';

  @override
  String get projectCreateTesters => 'Sinovchilar';

  @override
  String get projectCreateTestersHint => 'Sinovchi tanlang';

  @override
  String get projectCreateActive => 'Faolmi?';

  @override
  String get projectCreateRequiredError =>
      'Nomi, titul, menejer va muddat majburiy';

  @override
  String get projectCreateSuccess => 'Loyiha qo‘shildi';

  @override
  String get projectStatusPlanning => 'Rejalashtirilmoqda';

  @override
  String get projectStatusActive => 'Faol';

  @override
  String get projectStatusOverdue => 'Muddati o‘tgan';

  @override
  String get projectStatusCompleted => 'Yakunlangan';

  @override
  String get projectStatusCancelled => 'Bekor qilingan';

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

  @override
  String get usersEmpty => 'Hozircha foydalanuvchilar yo\'q';

  @override
  String get userFullNameLabel => 'Ism sharifi:';

  @override
  String get userPositionLabel => 'Lavozimi:';

  @override
  String get userRoleLabel => 'Rol:';

  @override
  String get userSalaryLabel => 'Oylik maoshi:';

  @override
  String get userBalanceLabel => 'Balansi:';

  @override
  String get usersFilterAllPositions => 'Barcha lavozimlar';

  @override
  String get usersFilterAllRoles => 'Barcha rollar';

  @override
  String get usersSortNameAsc => 'A dan Z gacha';

  @override
  String get usersSortNameDesc => 'Z dan A gacha';

  @override
  String get usersSortNewest => 'Yangi → Eski';

  @override
  String get usersSortOldest => 'Eski → Yangi';

  @override
  String get userDetailTitle => 'Foydalanuvchining ma’lumotlari';

  @override
  String get userDetailFullName => 'Ism Sharifi';

  @override
  String get userDetailCreatedAt => 'Yaratilgan vaqt';

  @override
  String get userDetailPhone => 'Telefon raqami';

  @override
  String get userDetailCard => 'Karta raqami';

  @override
  String get userDetailSalary => 'Oylik maosh';

  @override
  String get userDetailBalance => 'Balansi';

  @override
  String get userDetailDistrict => 'Tuman';

  @override
  String get userDetailPassport => 'Passport ma’lumotlari';

  @override
  String get userDetailPassportImage => 'Passport rasmi';

  @override
  String get userDetailPosition => 'Lavozimi';

  @override
  String get userDetailRole => 'Rolli';

  @override
  String get financeExpenseRequests => 'Xarajat so\'rovlari';

  @override
  String get financeWages => 'Ish haqi';

  @override
  String get financeHistory => 'Tarix';

  @override
  String get ledgerEmpty => 'Hozircha yozuvlar yo\'q';

  @override
  String get ledgerTypeLabel => 'Turi:';

  @override
  String get ledgerAmountLabel => 'Miqdor:';

  @override
  String get ledgerDateLabel => 'Sana:';

  @override
  String get ledgerTypeExpense => 'Chiqim';

  @override
  String get ledgerTypeIncome => 'Kirim';

  @override
  String get ledgerDetailTitle => 'Tarix ma’lumotlari';

  @override
  String get ledgerDetailExpenseType => 'Xarajat turi';

  @override
  String get ledgerDetailAmount => 'Miqdor';

  @override
  String get ledgerDetailConfirmedAt => 'Tastiqlangan vaqt';

  @override
  String get ledgerFilterExpenseType => 'Xarajat turi';

  @override
  String get ledgerFilterExpenseTypeHint => 'Xarajat turini tanlang';

  @override
  String get ledgerFilterDateRange => 'Sana oralig\'i';

  @override
  String get ledgerFilterAmount => 'Miqdor';

  @override
  String get payrollEmpty => 'Hozircha yozuvlar yo\'q';

  @override
  String get payrollMonthLabel => 'Oy:';

  @override
  String get payrollKpiLabel => 'KPI bonus:';

  @override
  String get payrollTotalLabel => 'Jami miqdori:';

  @override
  String get payrollDetailTitle => 'Ish haqi ma’lumotlari';

  @override
  String get payrollMonthField => 'Oy';

  @override
  String get payrollSalaryField => 'Oylik maosh (UZS)';

  @override
  String get payrollKpiField => 'KPI bonus';

  @override
  String get payrollPenaltyField => 'Jarima miqdori';

  @override
  String get payrollTotalField => 'Jami miqdori';

  @override
  String get payrollConfirmButton => 'Tasdiqlash';

  @override
  String get payrollConfirmSuccess => 'Ish haqi tasdiqlandi';

  @override
  String get payrollConfirmDialogTitle => 'Ish haqini tasdiqlaysizmi?';

  @override
  String get payrollConfirmDialogSubtitle =>
      'Tasdiqlangandan so\'ng bu amalni bekor qilib bo\'lmaydi';

  @override
  String get payrollFilterMonth => 'Oy';

  @override
  String get payrollFilterMonthHint => 'Oy tanlang';

  @override
  String get payrollFilterCreatedRange => 'Yaratilgan vaqti oralig\'i';

  @override
  String get payrollFilterTotal => 'Jami miqdori (UZS)';

  @override
  String get payrollFilterPenalty => 'Jarima miqdori';

  @override
  String get payrollFilterApply => 'Qidirish';

  @override
  String get expenseRequestProjectLabel => 'Loyiha:';

  @override
  String get expenseRequestTypeLabel => 'Xarajat turi:';

  @override
  String get expenseRequestAmountLabel => 'Summasi:';

  @override
  String get expenseRequestFilterCategory => 'Toifa';

  @override
  String get expenseRequestFilterCategoryHint => 'Toifani tanlang';

  @override
  String get expenseRequestFilterAmount => 'Summa';

  @override
  String get expenseRequestFilterPaidRange => 'To\'langan vaqti oralig\'i';

  @override
  String get expenseRequestFilterConfirmedRange =>
      'Tasdiqlangan vaqti oralig\'i';
}
