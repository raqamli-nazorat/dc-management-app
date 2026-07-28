import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../bloc/daily_plans_bloc.dart';
import '../widgets/daily_plan_card.dart';

class DailyPlansPage extends StatelessWidget {
  const DailyPlansPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => getIt<DailyPlansBloc>()..add(const DailyPlansRequested()),
    child: const _DailyPlansView(),
  );
}

class _DailyPlansView extends StatelessWidget {
  const _DailyPlansView();

  Future<void> _refresh(BuildContext context) {
    final bloc = context.read<DailyPlansBloc>();
    bloc.add(const DailyPlansRequested());
    return bloc.stream.firstWhere(
      (state) => state.status != DailyPlansStatus.loading,
    );
  }

  Future<void> _openEditor(BuildContext context, [DailyPlan? plan]) async {
    final router = GoRouter.of(context);
    final bool? saved;
    if (plan == null) {
      saved = await router.pushNamed<bool>(Routes.dailyPlanCreate.name);
    } else {
      saved = await router.pushNamed<bool>(
        Routes.dailyPlanEdit.name,
        extra: plan,
        pathParameters: {'id': plan.id.toString()},
      );
    }
    if (!context.mounted || saved != true) return;
    await _refresh(context);
  }

  Future<void> _confirmDelete(BuildContext context, DailyPlan plan) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.dailyPlansDeleteTitle),
        content: Text(l10n.dailyPlansDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.dailyPlansCancel),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.dailyPlansDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<DailyPlansBloc>().add(DailyPlanDeleted(plan.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return BlocListener<DailyPlansBloc, DailyPlansState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        switch (state.message) {
          case DailyPlansMessage.planDeleted:
            AppToast.showSuccess(context, title: l10n.dailyPlansDeleted);
          case DailyPlansMessage.failure:
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.failure?.message,
            );
          case DailyPlansMessage.planSaved:
          case null:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: Column(
            children: [
              _Header(),
              Expanded(
                child: RefreshIndicator(
                  color: colors.accentSub,
                  onRefresh: () => _refresh(context),
                  child: BlocBuilder<DailyPlansBloc, DailyPlansState>(
                    builder: (context, state) {
                      if (state.status == DailyPlansStatus.loading ||
                          state.status == DailyPlansStatus.initial) {
                        return const _ScrollableCenter(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (state.status == DailyPlansStatus.failure &&
                          state.plans.isEmpty) {
                        return _ScrollableCenter(
                          child: TextButton(
                            onPressed: () => context.read<DailyPlansBloc>().add(
                              const DailyPlansRequested(),
                            ),
                            child: l10n.commonRetry
                                .s(14.sp)
                                .w(700)
                                .c(colors.textAccent),
                          ),
                        );
                      }
                      if (state.plans.isEmpty) {
                        return _ScrollableCenter(
                          child: l10n.dailyPlansEmpty
                              .s(14.sp)
                              .w(500)
                              .c(colors.textSub),
                        );
                      }
                      return ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                        itemCount: state.plans.length,
                        separatorBuilder: (_, _) => SizedBox(height: 12.h),
                        itemBuilder: (_, index) {
                          final plan = state.plans[index];
                          return DailyPlanCard(
                            plan: plan,
                            onTap: () => _openEditor(context, plan),
                            onLongPress: () => _confirmDelete(context, plan),
                            onPlanToggle: () =>
                                context.read<DailyPlansBloc>().add(
                                  DailyPlanSaved(
                                    DailyPlanInput(
                                      title: plan.title,
                                      color: plan.color,
                                      isDone: !plan.isDone,
                                    ),
                                    id: plan.id,
                                  ),
                                ),
                            onItemToggle: (item) =>
                                context.read<DailyPlansBloc>().add(
                                  DailyPlanItemSaved(
                                    planId: plan.id,
                                    item: item,
                                    isDone: !item.isDone,
                                  ),
                                ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: InkWell(
                    onTap: () => _openEditor(context),
                    borderRadius: BorderRadius.circular(20.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.accentStrong,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow,
                            offset: Offset(0, 4.h),
                            blurRadius: 12.r,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 15.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.icons.icDailyPlanBookmark.svg(
                              width: 16.w,
                              height: 16.w,
                              colorFilter: ColorFilter.mode(
                                colors.iconWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            l10n.dailyPlansAdd
                                .s(15.sp)
                                .w(800)
                                .c(colors.textWhite),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          InkWell(
            onTap: context.pop,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          Expanded(
            child: l10n.dailyPlansMyTasks
                .s(17.sp)
                .w(800)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }
}

class _ScrollableCenter extends StatelessWidget {
  const _ScrollableCenter({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: constraints.maxHeight,
        child: Center(child: child),
      ),
    ),
  );
}
