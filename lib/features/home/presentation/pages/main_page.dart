import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/app_options.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';

/// "Bosh sahifa" tabining tanasi — header (foydalanuvchi ma’lumotlari) +
/// vaqtinchalik tema test paneli.
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProfileBloc>(
      create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
      child: const _MainView(),
    );
  }
}

class _MainView extends StatelessWidget {
  const _MainView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _Header(),
          // TODO: tanlangan tab tanasi bilan almashtiriladi.
          Expanded(child: _ThemeToggleTestPanel()),
        ],
      ),
    );
  }
}

/// Main page header: avatar + ism/rol + amal tugmalari (kunlik vazifa,
/// bildirishnoma). Ma’lumotlar `ProfileBloc`dan (`/users/me/`) olinadi.
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final profile = state.profile;
        final loading = state.status == ProfileStatus.loading ||
            state.status == ProfileStatus.initial;
        final name = profile?.displayName ?? '';
        final role = profile?.displaySubtitle ?? l10n.roleEmployee;

        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          child: Row(
            children: [
              TuiAvatar(initial: name.isEmpty ? '?' : name, size: 40),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    (loading && name.isEmpty ? '...' : name)
                        .s(14.sp)
                        .w(800)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 2.h),
                    role
                        .s(11.sp)
                        .w(500)
                        .c(colors.textSub)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _HeaderIconButton(icon: Assets.icons.icTaskDaliy, onTap: () {}),
              SizedBox(width: 8.w),
              _HeaderIconButton(
                icon: Assets.icons.icNotification,
                onTap: () => context.pushNamed(Routes.notifications.name),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeStrong, width: 1.w),
        ),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Center(
            child: icon.svg(
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

/// TEMPORARY: tema rejimini almashtirish uchun test paneli. Dizayn bo‘yicha
/// bu yerda tab tanasi bo‘ladi — panel faqat light/dark tekshirish uchun turadi.
class _ThemeToggleTestPanel extends StatelessWidget {
  const _ThemeToggleTestPanel();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final options = AppOptions.of(context);

    void setMode(ThemeMode mode) =>
        AppOptions.update(context, options.copyWith(themeMode: mode));

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          'Theme (test)'.s(13.sp).w(600).c(colors.textSub),
          SizedBox(height: 12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in ThemeMode.values) ...[
                _ModeChip(
                  label: mode.name,
                  selected: options.themeMode == mode,
                  onTap: () => setMode(mode),
                ),
                SizedBox(width: 8.w),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.accentSub : colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? colors.strokeAccent : colors.strokeStrong,
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: label
              .s(12.sp)
              .w(600)
              .c(selected ? colors.textWhite : colors.textSub),
        ),
      ),
    );
  }
}
