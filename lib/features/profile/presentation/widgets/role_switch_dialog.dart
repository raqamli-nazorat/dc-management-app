import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/bloc/role_select_bloc.dart';
import '../../../auth/presentation/role/role_presentation.dart';

/// Rol almashtirish dialogi — foydalanuvchining barcha rollari ro'yxati,
/// faol rol chegara (border) bilan ajratilgan. Rol tanlanganda backendga
/// yoziladi (`PATCH /users/me/`), muvaffaqiyatda dialog yopilib [onSwitched]
/// chaqiriladi (chaqiruvchi sessiya/profilni yangilaydi va toast ko'rsatadi).
///
/// Ko'rsatish uchun [showRoleSwitchDialog]dan foydalaning.
class RoleSwitchDialog extends StatelessWidget {
  const RoleSwitchDialog({
    super.key,
    required this.roles,
    required this.activeRole,
    required this.onSwitched,
  });

  final List<String> roles;
  final String activeRole;
  final void Function(String role) onSwitched;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: colors.backgroundBase,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: BlocConsumer<RoleSelectBloc, RoleSelectState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == RoleSelectStatus.success &&
              state.submittingRole != null) {
            final role = state.submittingRole!;
            Navigator.of(context).pop();
            onSwitched(role);
          } else if (state.status == RoleSelectStatus.failure) {
            final message = state.failure is NetworkFailure
                ? l10n.networkError
                : l10n.commonError;
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: colors.errorStrong,
                  content: message.s(14.sp).w(500).c(colors.textWhite),
                ),
              );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.strokeSoft,
                      borderRadius: BorderRadius.circular(1.r),
                    ),
                    child: SizedBox(width: 24.w, height: 3.h),
                  ),
                ),
                SizedBox(height: 16.h),
                Center(
                  child: l10n.profileRoleManage
                      .s(19.sp)
                      .w(800)
                      .c(colors.iconStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(height: 24.h),
                for (var i = 0; i < roles.length; i++) ...[
                  if (i > 0) SizedBox(height: 12.h),
                  _RoleOptionTile(
                    role: roles[i],
                    active: roles[i] == activeRole,
                    loading:
                        state.isLoading && state.submittingRole == roles[i],
                    enabled: !state.isLoading,
                    onTap: () => context
                        .read<RoleSelectBloc>()
                        .add(RoleSelectSubmitted(roles[i])),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleOptionTile extends StatelessWidget {
  const _RoleOptionTile({
    required this.role,
    required this.active,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final String role;
  final bool active;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final presentation = RolePresentation.of(l10n, role);
    final radius = BorderRadius.circular(16.r);

    return Opacity(
      opacity: enabled || loading ? 1 : 0.5,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: radius,
          border: active
              ? Border.all(color: colors.strokeStrong, width: 1.w)
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: radius,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (loading)
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: colors.iconStrong,
                      ),
                    )
                  else
                    presentation.icon.svg(
                      width: 20.w,
                      height: 20.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: presentation.label
                        .s(13.sp)
                        .w(800)
                        .c(colors.textStrong)
                        .a(TextAlign.center)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rol almashtirish dialogini ko'rsatadi. [onSwitched] backend tasdiqlangandan
/// so'ng (dialog yopilgach) chaqiriladi — chaqiruvchi sessiya + profilni
/// yangilaydi va toast chiqaradi.
Future<void> showRoleSwitchDialog(
  BuildContext context, {
  required List<String> roles,
  required String activeRole,
  required void Function(String role) onSwitched,
}) {
  final colors = AppColors.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: colors.black.withValues(alpha: 0.6),
    builder: (_) => BlocProvider<RoleSelectBloc>(
      create: (_) => getIt<RoleSelectBloc>(),
      child: RoleSwitchDialog(
        roles: roles,
        activeRole: activeRole,
        onSwitched: onSwitched,
      ),
    ),
  );
}
