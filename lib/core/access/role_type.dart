/// Rol kaliti (API xom stringi) — backend `/users/me/`dagi `active_role` va
/// login javobidagi `roles` aynan shu 5 ta xom qiymatni yuboradi: `admin`,
/// `manager`, `employee`, `auditor`, `accountant`. [fromRaw] shularni
/// kanonik enumga aylantiradi (case-insensitive/trim — himoya uchun,
/// alias emas).
///
/// [RolePresentation.of] (`features/auth/presentation/role/role_presentation.dart`)
/// shu enumga tayanadi — xom qiymat parsing ikki joyda saqlanmaydi.
enum RoleType {
  admin,
  manager,
  employee,
  auditor,
  accountant,
  unknown;

  static RoleType fromRaw(String raw) {
    switch (raw.toLowerCase().trim()) {
      case 'admin':
        return RoleType.admin;
      case 'manager':
        return RoleType.manager;
      case 'employee':
        return RoleType.employee;
      case 'auditor':
        return RoleType.auditor;
      case 'accountant':
        return RoleType.accountant;
      default:
        return RoleType.unknown;
    }
  }
}
