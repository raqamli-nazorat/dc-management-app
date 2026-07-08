import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/meetings_bloc.dart';
import '../widgets/meeting_card.dart';

/// Yig‘ilishlar ro‘yxati ekrani (`GET /meetings/`).
class MeetingsPage extends StatelessWidget {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MeetingsBloc>(
      create: (_) => getIt<MeetingsBloc>()..add(const MeetingsRequested()),
      child: const _MeetingsView(),
    );
  }
}

class _MeetingsView extends StatelessWidget {
  const _MeetingsView();

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<MeetingsBloc>();
    bloc.add(const MeetingsRequested());
    return bloc.stream.firstWhere((s) => s.status != MeetingsStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _MeetingsHeader(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: () => _onRefresh(context),
                child: BlocBuilder<MeetingsBloc, MeetingsState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case MeetingsStatus.loading:
                      case MeetingsStatus.initial:
                        return const _CenteredScrollable(
                          child: CircularProgressIndicator(),
                        );
                      case MeetingsStatus.failure:
                        return _CenteredScrollable(
                          child: _ErrorState(
                            failure: state.failure,
                            onRetry: () => context
                                .read<MeetingsBloc>()
                                .add(const MeetingsRequested()),
                          ),
                        );
                      case MeetingsStatus.success:
                        if (state.items.isEmpty) {
                          return _CenteredScrollable(
                            child: AppLocalizations.of(context)
                                .meetingsEmpty
                                .s(14.sp)
                                .w(500)
                                .c(colors.textSub),
                          );
                        }
                        return ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          itemCount: state.items.length,
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (_, i) =>
                              MeetingCard(meeting: state.items[i]),
                        );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ikki qatorli sarlavha: (1) orqaga + "Yig‘ilish qo‘shish" + bildirishnoma,
/// (2) "Yig‘ilishlar" + qidiruv + filtr. Qo‘shish/qidiruv/filtr — hozircha
/// stub (tegishli oqim dizayni yo‘q).
class _MeetingsHeader extends StatelessWidget {
  const _MeetingsHeader();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Assets.icons.icArrowLeftLarge.svg(
                    width: 24.w,
                    height: 24.w,
                    colorFilter:
                        ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
                  ),
                ),
              ),
              const Spacer(),
              _AddMeetingButton(onTap: () {}),
              SizedBox(width: 12.w),
              _SquareIconButton(
                icon: Assets.icons.icProfileNotification,
                background: colors.backgroundElevation1,
                borderColor: colors.strokeSub,
                onTap: () => context.pushNamed(Routes.notifications.name),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: l10n.meetingsTitle
                    .s(17.sp)
                    .w(800)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 12.w),
              _SquareIconButton(
                icon: Assets.icons.icSearch,
                background: colors.backgroundElevation1,
                size: 40,
                iconSize: 16,
                onTap: () {},
              ),
              SizedBox(width: 12.w),
              _SquareIconButton(
                icon: Assets.icons.icFilter,
                background: colors.backgroundElevation1,
                size: 40,
                iconSize: 16,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddMeetingButton extends StatelessWidget {
  const _AddMeetingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accentStrong,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: SizedBox(
            height: 20.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.icons.icShareNodes.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter:
                      ColorFilter.mode(colors.textWhite, BlendMode.srcIn),
                ),
                SizedBox(width: 8.w),
                l10n.meetingAdd.s(13.sp).w(800).c(colors.textWhite),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.background,
    required this.onTap,
    this.size = 36,
    this.iconSize = 20,
    this.borderColor,
  });

  final SvgGenImage icon;
  final Color background;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: borderColor ?? colors.strokeSoft,
            width: 1.w,
          ),
        ),
        child: SizedBox(
          width: size.w,
          height: size.w,
          child: Center(
            child: icon.svg(
              width: iconSize.w,
              height: iconSize.w,
              colorFilter:
                  ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}

class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.failure, required this.onRetry});

  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final message =
        failure is NetworkFailure ? l10n.networkError : l10n.commonError;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          message.s(14.sp).w(500).c(colors.textSub).a(TextAlign.center),
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onRetry,
            child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
          ),
        ],
      ),
    );
  }
}
