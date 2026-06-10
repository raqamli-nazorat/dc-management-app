import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// Rol kaliti (API) → ko‘rsatiladigan nom + markazlashgan SVG ikonka.
///
/// Ikonkalar generatsiya qilingan `Assets` sinfidan olinadi (qattiq kodlanmaydi).
/// Noma'lum kalitlar uchun xom qiymat capitalize qilinadi va default ikonka.
class RolePresentation {
  const RolePresentation({required this.label, required this.icon});

  final String label;
  final SvgGenImage icon;

  static RolePresentation of(AppLocalizations l10n, String role) {
    switch (role.toLowerCase().trim()) {
      case 'admin':
      case 'administrator':
        return RolePresentation(
          label: l10n.roleAdministrator,
          icon: Assets.icons.icBuildings,
        );
      case 'manager':
      case 'menejer':
        return RolePresentation(
          label: l10n.roleManager,
          icon: Assets.icons.icBreifcase,
        );
      case 'accountant':
      case 'hisobchi':
        return RolePresentation(
          label: l10n.roleAccountant,
          icon: Assets.icons.icDatabese,
        );
      case 'supervisor':
      case 'controller':
      case 'nazoratchi':
        return RolePresentation(
          label: l10n.roleSupervisor,
          icon: Assets.icons.icGlobe,
        );
      case 'employee':
      case 'xodim':
        return RolePresentation(
          label: l10n.roleEmployee,
          icon: Assets.icons.icUser,
        );
      default:
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
