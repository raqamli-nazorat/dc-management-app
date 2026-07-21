import 'role_type.dart';

/// Ilova bo'limlari — navigatsiya tab yoki tabga singdirilgan bo'lim
/// (masalan `analytics` — alohida tab emas, `MainPage` ichidagi grafiklar).
///
/// [applications] hali qurilmagan (Arizalar bo'limi) — matritsa oldindan
/// tayyor, feature qo'shilganda faqat `HomePage._sections`ga ulanadi.
enum AppSection {
  home,
  analytics,
  users,
  projects,
  finance,
  reports,
  applications,
}

/// Rolga qarab qaysi bo'lim ko'rinishi va harakat (CRUD) qilish mumkinligini
/// belgilaydigan yagona ruxsat matritsasi.
///
/// Foydalanish: `NavPermissions.isVisible(AppSection.users, role)`.
abstract final class NavPermissions {
  static const Map<AppSection, Set<RoleType>> _visibility = {
    AppSection.home: {
      RoleType.admin,
      RoleType.manager,
      RoleType.employee,
      RoleType.auditor,
      RoleType.accountant,
    },
    AppSection.analytics: {
      RoleType.admin,
      RoleType.manager,
      RoleType.employee,
      RoleType.auditor,
      // accountant — yashirilgan
    },
    AppSection.users: {
      RoleType.admin,
      RoleType.auditor,
      RoleType.accountant,
      // manager, employee — yashirilgan
    },
    AppSection.projects: {
      RoleType.admin,
      RoleType.manager,
      RoleType.employee,
      RoleType.auditor,
      // accountant — yashirilgan
    },
    AppSection.finance: {
      RoleType.admin,
      RoleType.manager,
      RoleType.employee,
      RoleType.auditor,
      RoleType.accountant,
    },
    AppSection.reports: {
      RoleType.admin,
      RoleType.manager,
      RoleType.employee,
      RoleType.auditor,
      RoleType.accountant,
    },
    AppSection.applications: {
      RoleType.admin,
      RoleType.manager,
      RoleType.auditor,
      // employee, accountant — yashirilgan (bo'lim hali qurilmagan)
    },
  };

  /// `role` uchun `unknown` bo'lsa (yoki matritsada yo'q bo'lim) — xavfsiz
  /// default: hech narsa ko'rinmaydi.
  static bool isVisible(AppSection section, RoleType role) =>
      _visibility[section]?.contains(role) ?? false;

  /// Faqat Nazoratchi (Auditor) uchun `false` — yaratish/tahrirlash/
  /// o'chirish/tasdiqlash tugmalarini yashirish uchun. O'z profilini
  /// tahrirlash / parol o'zgartirish shu bilan cheklanmaydi.
  static bool canPerformActions(RoleType role) => role != RoleType.auditor;

  /// `POST /users/` backendida yaratish huquqi faqat administratorga tegishli.
  static bool canCreateUser(RoleType role) => role == RoleType.admin;

  static bool canCreateProject(RoleType role) => role == RoleType.admin;

  /// Loyiha kartasidagi "Tahrirlash" va `/edit` sahifasiga kirish. Menejer
  /// kiradi, lekin faqat hujjatlarni o'zgartira oladi ([canEditProjectFields]).
  static bool canManageProject(RoleType role) =>
      role == RoleType.admin || role == RoleType.manager;

  /// Loyiha maydonlarini (nom, status, menejer, muddat…) tahrirlash — faqat
  /// admin. Menejerga forma readOnly, hujjatlar bo'limi ochiq.
  static bool canEditProjectFields(RoleType role) => role == RoleType.admin;

  static bool canDeleteProject(RoleType role) => role == RoleType.admin;

  /// Ariza yaratish — [isVisible]dagi [AppSection.applications]dan alohida
  /// ruxsat: Menejer va Xodim ariza yubora oladi (Xodim bo'limni ko'rmasa
  /// ham — uning yuborish nuqtasi boshqa joyda bo'ladi). Admin/Nazoratchi/
  /// Hisobchi hech qachon ariza yaratmaydi, bo'limni ko'rsa ham.
  static const Set<RoleType> _canCreateApplication = {
    RoleType.manager,
    RoleType.employee,
  };

  static bool canCreateApplication(RoleType role) =>
      _canCreateApplication.contains(role);

  /// Xarajat so'rovi yuborish — faqat Hisobchi va Xodim (ro'yxatdagi "So'rov
  /// yuborish" tugmasi shu bilan ko'rsatiladi).
  static const Set<RoleType> _canCreateExpenseRequest = {
    RoleType.accountant,
    RoleType.employee,
  };

  static bool canCreateExpenseRequest(RoleType role) =>
      _canCreateExpenseRequest.contains(role);
}
