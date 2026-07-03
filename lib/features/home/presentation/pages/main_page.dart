import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/nav_permissions.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../statistics/presentation/bloc/statistics_bloc.dart';
import '../../../statistics/presentation/widgets/chart_card.dart';
import '../../../statistics/presentation/widgets/meetings_donut_chart.dart';
import '../../../statistics/presentation/widgets/projects_bar_chart.dart';
import '../../../statistics/presentation/widgets/statistics_period_selector.dart';
import '../../../statistics/presentation/widgets/tasks_line_chart.dart';

/// "Bosh sahifa" tabining tanasi — header (foydalanuvchi ma’lumotlari) +
/// davr selektori + statistik grafiklar (vazifalar / loyihalar / yig‘ilishlar).
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (_) => getIt<ProfileBloc>()..add(const ProfileRequested()),
        ),
        BlocProvider<StatisticsBloc>(
          create: (_) =>
              getIt<StatisticsBloc>()..add(const StatisticsRequested()),
        ),
      ],
      child: const _MainView(),
    );
  }
}

class _MainView extends StatelessWidget {
  const _MainView();

  /// Statistika + profilni qayta yuklaydi va ikkalasi ham `loading`dan
  /// chiqquncha kutadi — `RefreshIndicator` shu Future tugaguncha aylanadi.
  Future<void> _onRefresh(BuildContext context) {
    final statisticsBloc = context.read<StatisticsBloc>();
    final profileBloc = context.read<ProfileBloc>();
    statisticsBloc.add(const StatisticsRequested());
    profileBloc.add(const ProfileRequested());
    return Future.wait([
      statisticsBloc.stream
          .firstWhere((s) => s.status != StatisticsStatus.loading),
      profileBloc.stream.firstWhere((s) => s.status != ProfileStatus.loading),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    // Sliver AppBar `CustomScrollView` ichida (pinned) — indikator shu
    // scrollable'ning tepasiga bog‘lanadi, shu bois AppBar balandligicha
    // pastga suriladi (aks holda ustidan chiqib qoladi).
    final appBarHeight = MediaQuery.paddingOf(context).top + 64.h;
    final role =
        context.select<SessionBloc, RoleType>((b) => b.state.roleType);
    final showAnalytics = NavPermissions.isVisible(
      AppSection.analytics,
      role,
    );

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (_, current) =>
          current.status == ProfileStatus.success && current.profile != null,
      listener: (context, state) => context
          .read<SessionBloc>()
          .add(SessionActiveRoleSynced(state.profile!.activeRole)),
      child: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        color: colors.accentSub,
        edgeOffset: appBarHeight,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 64.h,
              titleSpacing: 0,
              automaticallyImplyLeading: false,
              backgroundColor: colors.backgroundBase,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const _Header(),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 4.h),
                  if (showAnalytics) ...[
                    const _PeriodRow(),
                    SizedBox(height: 16.h),
                    const _StatisticsSection(),
                    SizedBox(height: 24.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Main page header: avatar + ism/rol + amal tugmalari (Arizalar,
/// bildirishnoma). Ma’lumotlar `ProfileBloc`dan (`/users/me/`) olinadi.
/// Arizalar tugmasi rolga qarab yashiriladi ([AppSection.applications]).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final roleType =
        context.select<SessionBloc, RoleType>((b) => b.state.roleType);
    final showApplications =
        NavPermissions.isVisible(AppSection.applications, roleType);

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
              Expanded(
                child: InkWell(
                  onTap: () => context.pushNamed(Routes.profile.name),
                  borderRadius: BorderRadius.circular(16.r),
                  child: Row(
                    children: [
                      _Avatar(url: profile?.avatar ?? '', initial: name),
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
                                .copyWith(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            SizedBox(height: 2.h),
                            role
                                .s(11.sp)
                                .w(500)
                                .c(colors.textSub)
                                .copyWith(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (showApplications) ...[
                SizedBox(width: 8.w),
                // Arizalar tugmasi — feature hali qurilmagan, onTap stub.
                _HeaderIconButton(
                  icon: Assets.icons.icTaskDaliy,
                  onTap: () {},
                ),
              ],
              SizedBox(width: 16.w),
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

/// Header avatar — Figma "Field" (40×40, radius 16, bordered) ichida
/// "tui-avatar" (32×32, radius 12): rasm bo‘lsa tasvir, aks holda bosh harf.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.initial});

  final String url;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    const innerSize = 32.0;
    final innerRadius = BorderRadius.circular(12.r);

    Widget inner;
    if (url.isNotEmpty) {
      inner = ClipRRect(
        borderRadius: innerRadius,
        child: CachedNetworkImage(
          imageUrl: url,
          width: innerSize.w,
          height: innerSize.w,
          fit: BoxFit.cover,
          placeholder: (_, _) => _AvatarLetter(initial: initial),
          errorWidget: (_, _, _) => _AvatarLetter(initial: initial),
        ),
      );
    } else {
      inner = _AvatarLetter(initial: initial);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.strokeStrong, width: 1.w),
      ),
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: Center(
          child: SizedBox(
            width: innerSize.w,
            height: innerSize.w,
            child: inner,
          ),
        ),
      ),
    );
  }
}

class _AvatarLetter extends StatelessWidget {
  const _AvatarLetter({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final letter = initial.isEmpty ? '?' : initial.characters.first.toUpperCase();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation3,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(child: letter.s(13.sp).w(800).c(colors.textSub)),
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
          color: colors.backgroundElevation1,
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

/// "Davrni tanlang" + segment selektori qatori.
class _PeriodRow extends StatelessWidget {
  const _PeriodRow();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: BlocBuilder<StatisticsBloc, StatisticsState>(
        buildWhen: (a, b) => a.period != b.period,
        builder: (context, state) {
          return Row(
            children: [
              Expanded(
                child: l10n.statPeriodSelect
                    .s(14.sp)
                    .w(600)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8.w),
              StatisticsPeriodSelector(
                selected: state.period,
                onChanged: (period) => context
                    .read<StatisticsBloc>()
                    .add(StatisticsPeriodChanged(period)),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Grafiklar bo‘limi — davr statistikasi holatiga qarab yuklanish / xato /
/// grafiklar ko‘rsatiladi.
class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        final stats = state.periodStatistics;

        if (stats == null) {
          if (state.status == StatisticsStatus.failure) {
            return _StatisticsError(failure: state.failure);
          }
          return const _StatisticsLoading();
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ChartCard(
                title: AppLocalizations.of(context).statTasksTitle,
                child: TasksLineChart(stats: stats.tasks),
              ),
              SizedBox(height: 16.h),
              ChartCard(
                title: AppLocalizations.of(context).statProjectsTitle,
                child: ProjectsBarChart(stats: stats.projects),
              ),
              SizedBox(height: 16.h),
              ChartCard(
                title: AppLocalizations.of(context).statMeetingsTitle,
                child: MeetingsDonutChart(stats: stats.meetings),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatisticsLoading extends StatelessWidget {
  const _StatisticsLoading();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 320.h,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.5.w,
          color: colors.accentSub,
        ),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  const _StatisticsError({required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final message =
        failure is NetworkFailure ? l10n.networkError : l10n.commonError;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          message
              .s(13.sp)
              .w(500)
              .c(colors.textSub)
              .copyWith(textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () =>
                context.read<StatisticsBloc>().add(const StatisticsRequested()),
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
