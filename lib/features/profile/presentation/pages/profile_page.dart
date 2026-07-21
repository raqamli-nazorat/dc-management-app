import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/role/role_presentation.dart';
import '../../domain/entities/profile.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/logout_confirm_dialog.dart';
import '../widgets/role_switch_dialog.dart';
import '../widgets/theme_switch_sheet.dart';

/// Profil sahifasi — foydalanuvchi ma'lumotlari + hisob sozlamalari ro'yxati.
/// Home ustidan (AppBar user ma'lumotlari bosilganda) push qilinadi.
/// Ma'lumotlar `ProfileBloc`dan (`GET /users/me/`) olinadi.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  /// Ilova versiyasi (dizaynda "Versiya 1.0" — sozlamalar ro'yxati ost-kartasi).
  static const _appVersion = '1.0';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
      child: const _ProfileView(appVersion: _appVersion),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.appVersion});

  final String appVersion;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _ProfileAppBar(),
            Expanded(
              child: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state.profile == null) {
                    if (state.status == ProfileStatus.failure) {
                      return _ProfileError(failure: state.failure);
                    }
                    return _ProfileLoading(color: colors.accentSub);
                  }
                  return _ProfileBody(
                    profile: state.profile!,
                    appVersion: appVersion,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// AppBar: orqaga tugmasi + sarlavha (rolga bog'liq) + chiqish (logout) tugmasi.
class _ProfileAppBar extends StatelessWidget {
  const _ProfileAppBar();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    final role = context.select<ProfileBloc, String>(
      (b) => b.state.profile == null
          ? l10n.roleEmployee
          : RolePresentation.of(l10n, b.state.profile!.activeRole).label,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          _AppBarButton(
            icon: Assets.icons.icArrowLeftLarge,
            color: colors.iconStrong,
            onTap: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: l10n
                  .profileTitle(role)
                  .s(17.sp)
                  .w(800)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          _AppBarButton(
            icon: Assets.icons.icArrowRightExit,
            color: colors.errorSub,
            onTap: () => showLogoutConfirmDialog(context),
          ),
        ],
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final SvgGenImage icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: icon.svg(
          width: 24.w,
          height: 24.w,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
      ),
    );
  }
}

/// Profil sahifa tanasi — ma'lumot kartasi + sozlamalar ro'yxati + ost "Ilova
/// haqida" kartasi (ekranning pastiga bog'lanadi).
class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.appVersion});

  final Profile profile;
  final String appVersion;

  /// Rol almashtirish dialogini ochadi. Backend tasdiqlangach (dialog yopilgach)
  /// lokal sessiya + profil yangilanadi va muvaffaqiyat toasti chiqadi.
  void _openRoleSwitch(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sessionBloc = context.read<SessionBloc>();
    final profileBloc = context.read<ProfileBloc>();

    showRoleSwitchDialog(
      context,
      roles: profile.roles,
      activeRole: profile.activeRole,
      onSwitched: (role) {
        sessionBloc.add(SessionRoleSelected(role));
        profileBloc.add(const ProfileRequested());
        final label = RolePresentation.of(l10n, role).label;
        AppToast.showSuccess(
          context,
          title: l10n.roleSwitchedTitle(label),
          message: l10n.roleSwitchedSubtitle(label),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileInfoCard(
                      profile: profile,
                      onTap: () async {
                        final updated = await context.pushNamed<bool>(
                          Routes.profileEdit.name,
                        );
                        if (updated == true && context.mounted) {
                          context.read<ProfileBloc>().add(
                            const ProfileRequested(),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 10.h),
                    _RoleManageRow(onTap: () => _openRoleSwitch(context)),
                    SizedBox(height: 20.h),
                    _SettingsRow(
                      icon: Assets.icons.icLock,
                      label: l10n.profileSecurity,
                      onTap: () => context.pushNamed(Routes.security.name),
                    ),
                    SizedBox(height: 12.h),
                    _SettingsRow(
                      icon: Assets.icons.icProfileNotification,
                      label: l10n.notificationsTitle,
                      onTap: () => context.pushNamed(Routes.notifications.name),
                    ),
                    SizedBox(height: 12.h),
                    _SettingsRow(
                      icon: Assets.icons.icSoon,
                      label: l10n.profileTheme,
                      onTap: () => showThemeSwitchSheet(context),
                    ),
                    const Spacer(),
                    SizedBox(height: 24.h),
                    _AboutCard(version: appVersion),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Foydalanuvchi ma'lumot kartasi — avatar + ism/rol + tahrir ikonkasi.
class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.profile, required this.onTap});

  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              _ProfileAvatar(url: profile.avatar, initial: profile.displayName),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    profile.displayName
                        .s(15.sp)
                        .w(800)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2.h),
                    profile.displaySubtitle
                        .s(13.sp)
                        .w(500)
                        .c(colors.textSub)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Assets.icons.icPersonalInformationArrow.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dumaloq (48×48) avatar — rasm bo'lsa tasvir, aks holda bosh harf.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url, required this.initial});

  final String url;
  final String initial;

  @override
  Widget build(BuildContext context) {
    const size = 48.0;

    Widget child;
    if (url.isNotEmpty) {
      child = CachedNetworkImage(
        imageUrl: url,
        width: size.w,
        height: size.w,
        fit: BoxFit.cover,
        placeholder: (_, _) => _AvatarLetter(initial: initial),
        errorWidget: (_, _, _) => _AvatarLetter(initial: initial),
      );
    } else {
      child = _AvatarLetter(initial: initial);
    }

    return ClipOval(
      child: SizedBox(width: size.w, height: size.w, child: child),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  const _AvatarLetter({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final letter = initial.isEmpty
        ? '?'
        : initial.characters.first.toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(color: colors.avatarPlaceholder),
      child: Center(child: letter.s(18.sp).w(800).c(colors.textSub)),
    );
  }
}

/// "Rol boshqarish" qatori — chegarali (border), shaffof fon, o'ng tomonda
/// yuqori/past almashtirish (switch) ikonkasi.
class _RoleManageRow extends StatelessWidget {
  const _RoleManageRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: colors.strokeStrong, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Assets.icons.icPersonalInformationIcon.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconAccent,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: l10n.profileRoleManage
                    .s(14.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8.w),
              Assets.icons.icPersonalInformationSwitch.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hisob sozlamalari qatori — leading ikonka + yozuv + o'ng "chevron" strelkasi.
class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              icon.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconAccent,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: label
                    .s(14.sp)
                    .w(500)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8.w),
              Assets.icons.icArrowRight.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ost-karta: "Ilova haqida" + "Versiya x.x".
class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: l10n.profileAbout
                  .s(14.sp)
                  .w(500)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(width: 8.w),
            l10n
                .profileVersion(version)
                .s(14.sp)
                .w(500)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _ProfileLoading extends StatelessWidget {
  const _ProfileLoading({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(strokeWidth: 2.5.w, color: color),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final message = failure is NetworkFailure
        ? l10n.networkError
        : l10n.commonError;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          message
              .s(13.sp)
              .w(500)
              .c(colors.textSub)
              .copyWith(textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () =>
                context.read<ProfileBloc>().add(const ProfileRequested()),
            borderRadius: BorderRadius.circular(12.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentSub,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: l10n.commonRetry.s(13.sp).w(600).c(colors.textWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
