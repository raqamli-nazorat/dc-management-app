import '../../../../core/access/role_type.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// Rol kaliti (API) → ko‘rsatiladigan nom + markazlashgan SVG ikonka.
///
/// Ikonkalar generatsiya qilingan `Assets` sinfidan olinadi (qattiq kodlanmaydi).
/// Xom qiymatni kanonik turga ajratish [RoleType.fromRaw] orqali — alias
/// ro'yxati shu yerda ikkinchi marta saqlanmaydi. Noma'lum kalitlar uchun
/// xom qiymat capitalize qilinadi va default ikonka.
class RolePresentation {
  const RolePresentation({required this.label, required this.icon});

  final String label;
  final SvgGenImage icon;

  static RolePresentation of(AppLocalizations l10n, String role) {
    switch (RoleType.fromRaw(role)) {
      case RoleType.admin:
        return RolePresentation(
          label: l10n.roleAdministrator,
          icon: Assets.icons.icBuildings,
        );
      case RoleType.manager:
        return RolePresentation(
          label: l10n.roleManager,
          icon: Assets.icons.icBreifcase,
        );
      case RoleType.accountant:
        return RolePresentation(
          label: l10n.roleAccountant,
          icon: Assets.icons.icDatabese,
        );
      case RoleType.auditor:
        return RolePresentation(
          label: l10n.roleSupervisor,
          icon: Assets.icons.icGlobe,
        );
      case RoleType.employee:
        return RolePresentation(
          label: l10n.roleEmployee,
          icon: Assets.icons.icUser,
        );
      case RoleType.unknown:
        return RolePresentation(
          label: _capitalize(role),
          icon: Assets.icons.icUser,
        );
    }
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
