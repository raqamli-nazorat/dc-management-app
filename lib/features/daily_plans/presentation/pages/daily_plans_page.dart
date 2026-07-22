import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../bloc/daily_plans_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return BlocListener<DailyPlansBloc, DailyPlansState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        switch (state.message) {
          case DailyPlansMessage.planSaved:
            AppToast.showSuccess(context, title: l10n.dailyPlansSaved);
          case DailyPlansMessage.planDeleted:
            AppToast.showSuccess(context, title: l10n.dailyPlansDeleted);
          case DailyPlansMessage.failure:
            AppToast.showError(
              context,
              title: l10n.commonError,
              message: state.failure?.message,
            );
          case null:
            break;
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: Column(
            children: [
              _Header(onAdd: () => _openPlanDialog(context)),
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
                        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                        itemCount: state.plans.length,
                        separatorBuilder: (_, _) => SizedBox(height: 14.h),
                        itemBuilder: (_, index) => _PlanCard(
                          plan: state.plans[index],
                          onEdit: () =>
                              _openPlanDialog(context, state.plans[index]),
                          onDelete: () =>
                              _confirmDelete(context, state.plans[index]),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPlanDialog(BuildContext context, [DailyPlan? plan]) =>
      showDialog<void>(
        context: context,
        builder: (_) => BlocProvider.value(
          value: context.read<DailyPlansBloc>(),
          child: _PlanDialog(plan: plan),
        ),
      );

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
}

class _Header extends StatelessWidget {
  const _Header({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icArrowLeftLarge.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: l10n.dailyPlansTitle
                .s(22.sp)
                .w(800)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(14.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentStrong,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Assets.icons.icPlus.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconWhite,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    l10n.dailyPlansAdd.s(12.sp).w(800).c(colors.textWhite),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.onEdit,
    required this.onDelete,
  });
  final DailyPlan plan;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final accent = switch (plan.color) {
      DailyPlanColor.red => colors.errorStrong,
      DailyPlanColor.green => colors.successStrong,
      DailyPlanColor.yellow => colors.taskStatusTodo,
      DailyPlanColor.blue => colors.accentStrong,
    };
    final date = plan.createdAt == null
        ? ''
        : DateFormat('EEEE, d-MMMM y', 'uz').format(plan.createdAt!);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: colors.strokeSub, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 12.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: date
                        .s(12.sp)
                        .w(800)
                        .c(colors.textWhite)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  _ActionIcon(
                    icon: Assets.icons.icPersonalInformationIcon,
                    onTap: onEdit,
                  ),
                  SizedBox(width: 6.w),
                  _ActionIcon(icon: Assets.icons.icTrash, onTap: onDelete),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () => context.read<DailyPlansBloc>().add(
                      DailyPlanSaved(
                        DailyPlanInput(
                          title: plan.title,
                          color: plan.color,
                          isDone: !plan.isDone,
                        ),
                        id: plan.id,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.backgroundElevation1.withValues(
                          alpha: .22,
                        ),
                        border: Border.all(
                          color: colors.strokeWhite.withValues(alpha: .35),
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 7.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Assets.icons.icCheck.svg(
                              width: 14.w,
                              height: 14.w,
                              colorFilter: ColorFilter.mode(
                                colors.iconWhite,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            (plan.isDone
                                    ? l10n.dailyPlansDone
                                    : l10n.dailyPlansUndone)
                                .s(11.sp)
                                .w(800)
                                .c(colors.textWhite),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                plan.title
                    .s(16.sp)
                    .w(800)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                SizedBox(height: 12.h),
                for (final item in plan.items)
                  _PlanItem(planId: plan.id, item: item),
                _AddItem(planId: plan.id),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, required this.onTap});
  final SvgGenImage icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10.r),
    child: Padding(
      padding: EdgeInsets.all(7.w),
      child: icon.svg(
        width: 16.w,
        height: 16.w,
        colorFilter: ColorFilter.mode(
          AppColors.of(context).iconWhite,
          BlendMode.srcIn,
        ),
      ),
    ),
  );
}

class _PlanItem extends StatelessWidget {
  const _PlanItem({required this.planId, required this.item});
  final int planId;
  final DailyPlanItem item;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: InkWell(
        onTap: () => context.read<DailyPlansBloc>().add(
          DailyPlanItemSaved(planId: planId, item: item, isDone: !item.isDone),
        ),
        borderRadius: BorderRadius.circular(10.r),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: item.isDone
                    ? colors.accentStrong
                    : colors.backgroundElevation3,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 22.w,
                height: 22.w,
                child: item.isDone
                    ? Center(
                        child: Assets.icons.icCheck.svg(
                          width: 13.w,
                          height: 13.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: item.title
                  .s(13.sp)
                  .w(600)
                  .c(item.isDone ? colors.textDisabled : colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItem extends StatefulWidget {
  const _AddItem({required this.planId});
  final int planId;
  @override
  State<_AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<_AddItem> {
  final _controller = TextEditingController();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    context.read<DailyPlansBloc>().add(
      DailyPlanItemSaved(planId: widget.planId, title: title),
    );
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation3,
            shape: BoxShape.circle,
          ),
          child: SizedBox(width: 22.w, height: 22.w),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (_) => _submit(),
            style: TextStyle(fontSize: 13.sp, color: colors.textStrong),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).dailyPlansItemHint,
              hintStyle: TextStyle(fontSize: 13.sp, color: colors.textSoft),
              isDense: true,
              border: InputBorder.none,
            ),
          ),
        ),
        InkWell(
          onTap: _submit,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.all(5.w),
            child: Assets.icons.icPlus.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(colors.iconAccent, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanDialog extends StatefulWidget {
  const _PlanDialog({this.plan});
  final DailyPlan? plan;
  @override
  State<_PlanDialog> createState() => _PlanDialogState();
}

class _PlanDialogState extends State<_PlanDialog> {
  late final _controller = TextEditingController(
    text: widget.plan?.title ?? '',
  );
  late DailyPlanColor _color = widget.plan?.color ?? DailyPlanColor.blue;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) return;
    context.read<DailyPlansBloc>().add(
      DailyPlanSaved(
        DailyPlanInput(title: _controller.text, color: _color),
        id: widget.plan?.id,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.overlaySurface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: colors.strokeAccent, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: l10n.dailyPlansAdd
                          .s(20.sp)
                          .w(800)
                          .c(colors.textStrong),
                    ),
                    InkWell(
                      onTap: () => context.pop(),
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.all(4.w),
                        child: Assets.icons.icClose.svg(
                          width: 20.w,
                          height: 20.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconSub,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                l10n.dailyPlansSubtitle.s(13.sp).w(500).c(colors.textSub),
                SizedBox(height: 20.h),
                TextField(
                  controller: _controller,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _save(),
                  style: TextStyle(fontSize: 16.sp, color: colors.textStrong),
                  decoration: InputDecoration(
                    hintText: l10n.dailyPlansNameHint,
                    hintStyle: TextStyle(
                      fontSize: 16.sp,
                      color: colors.textSoft,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 10.w,
                  children: DailyPlanColor.values
                      .map(
                        (color) => InkWell(
                          onTap: () => setState(() => _color = color),
                          borderRadius: BorderRadius.circular(20.r),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: _colorValue(colors, color),
                              shape: BoxShape.circle,
                              border: _color == color
                                  ? Border.all(
                                      color: colors.textStrong,
                                      width: 2.w,
                                    )
                                  : null,
                            ),
                            child: SizedBox(width: 28.w, height: 28.w),
                          ),
                        ),
                      )
                      .toList(),
                ),
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: l10n.dailyPlansCancel
                          .s(14.sp)
                          .w(700)
                          .c(colors.textSub),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: _save,
                      borderRadius: BorderRadius.circular(14.r),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.accentStrong,
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          child: l10n.dailyPlansAdd
                              .s(14.sp)
                              .w(800)
                              .c(colors.textWhite),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _colorValue(AppColors colors, DailyPlanColor color) => switch (color) {
    DailyPlanColor.red => colors.errorStrong,
    DailyPlanColor.green => colors.successStrong,
    DailyPlanColor.yellow => colors.taskStatusTodo,
    DailyPlanColor.blue => colors.accentStrong,
  };
}

class _ScrollableCenter extends StatelessWidget {
  const _ScrollableCenter({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, constraints) => SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: constraints.maxHeight,
        child: Center(child: child),
      ),
    ),
  );
}
