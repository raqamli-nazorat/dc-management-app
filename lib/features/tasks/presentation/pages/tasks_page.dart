import 'dart:async';

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
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../bloc/tasks_bloc.dart';
import '../widgets/task_card.dart';

/// Vazifalar ro'yxati ekrani (`GET /tasks/`).
class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TasksBloc>(
      create: (_) => getIt<TasksBloc>()..add(const TasksRequested()),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView();

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  final _scrollController = ScrollController();
  final _countdownNow = ValueNotifier<DateTime>(DateTime.now());
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _stopCountdownTimer();
    _countdownNow.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Oxiriga 300px qolganda keyingi sahifani so'raymiz (bloc qulflarni
  /// o'zi tekshiradi: reachedMax / isLoadingMore).
  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<TasksBloc>().add(const TasksLoadMore());
    }
  }

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<TasksBloc>();
    bloc.add(const TasksRequested());
    return bloc.stream.firstWhere((s) => s.status != TasksStatus.loading);
  }

  bool _hasActiveCountdown(Iterable<Task> items, DateTime now) {
    return items.any((task) => shouldShowTaskCountdown(task.deadline, now));
  }

  void _syncCountdownTimer(List<Task> items) {
    final now = DateTime.now();
    if (_hasActiveCountdown(items, now)) {
      _startCountdownTimer();
    } else {
      _stopCountdownTimer();
    }
  }

  void _startCountdownTimer() {
    if (_countdownTimer?.isActive ?? false) return;
    _countdownNow.value = DateTime.now();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final now = DateTime.now();
      _countdownNow.value = now;
      final items = context.read<TasksBloc>().state.items;
      if (!_hasActiveCountdown(items, now)) _stopCountdownTimer();
    });
  }

  void _stopCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _TasksHeader(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: () => _onRefresh(context),
                child: BlocConsumer<TasksBloc, TasksState>(
                  listener: (_, state) {
                    if (state.status == TasksStatus.success) {
                      _syncCountdownTimer(state.items);
                    } else {
                      _stopCountdownTimer();
                    }
                  },
                  builder: (context, state) {
                    switch (state.status) {
                      case TasksStatus.loading:
                      case TasksStatus.initial:
                        return const _CenteredScrollable(
                          child: CircularProgressIndicator(),
                        );
                      case TasksStatus.failure:
                        return _CenteredScrollable(
                          child: _ErrorState(
                            failure: state.failure,
                            onRetry: () => context.read<TasksBloc>().add(
                              const TasksRequested(),
                            ),
                          ),
                        );
                      case TasksStatus.success:
                        if (state.items.isEmpty) {
                          return _CenteredScrollable(
                            child: AppLocalizations.of(
                              context,
                            ).tasksEmpty.s(14.sp).w(500).c(colors.textSub),
                          );
                        }
                        return ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          // Oxirgi element — footer spinner (yana sahifa bo'lsa).
                          itemCount:
                              state.items.length +
                              (state.hasReachedMax ? 0 : 1),
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (_, i) {
                            if (i >= state.items.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Center(
                                  child: SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.w,
                                      color: colors.accentSub,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final task = state.items[i];
                            return TaskCard(
                              task: task,
                              countdownTicker: _countdownNow,
                              onDelete: () => context.read<TasksBloc>().add(
                                TasksTaskDeleted(task.id),
                              ),
                            );
                          },
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

/// Ikki qatorli sarlavha: (1) orqaga + "Vazifa qo'shish" + bildirishnoma,
/// (2) "Vazifalar" + qidiruv + filtr. Qo'shish/qidiruv/filtr — hozircha stub.
class _TasksHeader extends StatelessWidget {
  const _TasksHeader();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

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
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _AddTaskButton(
                onTap: () async {
                  final bloc = context.read<TasksBloc>();
                  final created = await context.pushNamed<bool>(
                    Routes.taskCreate.name,
                  );
                  // Yangi vazifa qo'shilgan bo'lsa ro'yxatni qayta yuklaymiz.
                  if (created == true) bloc.add(const TasksRequested());
                },
              ),
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
        const _SearchFilterRow(),
      ],
    );
  }
}

/// Sarlavha + qidiruv + filtr qatori. Qidiruv ikonkasi bosilganda yondagi
/// widgetlar o'rnini to'liq kenglikdagi qidiruv maydoni egallaydi (animatsiya
/// bilan), fokus oladi va yozilgani `search` param orqali so'raladi. Filtr
/// tugmasi ustidagi nuqta — biror filtr faolligini bildiradi.
class _SearchFilterRow extends StatefulWidget {
  const _SearchFilterRow();

  @override
  State<_SearchFilterRow> createState() => _SearchFilterRowState();
}

class _SearchFilterRowState extends State<_SearchFilterRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _statusLayerLink = LayerLink();
  final _statusPortalController = OverlayPortalController();
  Timer? _debounce;
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _openSearch() {
    _statusPortalController.hide();
    setState(() => _searching = true);
    // Maydon animatsiyada quriladi — keyingi kadrda fokus so'raymiz.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _closeSearch() {
    _debounce?.cancel();
    final hadText = _controller.text.isNotEmpty;
    _controller.clear();
    _focus.unfocus();
    setState(() => _searching = false);
    if (hadText) context.read<TasksBloc>().add(const TasksSearchChanged(''));
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<TasksBloc>().add(TasksSearchChanged(value.trim()));
      }
    });
  }

  Future<void> _openFilter() async {
    _statusPortalController.hide();
    final bloc = context.read<TasksBloc>();
    final result = await context.pushNamed<Object?>(
      Routes.taskFilter.name,
      extra: bloc.state.filter,
    );
    if (result is TaskFilter) bloc.add(TasksFilterChanged(result));
  }

  void _toggleStatusDropdown() {
    FocusScope.of(context).unfocus();
    if (_statusPortalController.isShowing) {
      _statusPortalController.hide();
    } else {
      _statusPortalController.show();
    }
  }

  void _selectStatus(TaskStatus status) {
    _statusPortalController.hide();
    final bloc = context.read<TasksBloc>();
    bloc.add(TasksFilterChanged(bloc.state.filter.copyWithStatus(status)));
  }

  Widget _buildStatusOverlay(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _statusPortalController.hide,
          ),
        ),
        CompositedTransformFollower(
          link: _statusLayerLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: Offset(0, 8.h),
          child: BlocBuilder<TasksBloc, TasksState>(
            buildWhen: (p, c) =>
                p.filter.status != c.filter.status ||
                p.statusPages != c.statusPages,
            builder: (context, state) => SizedBox(
              width: 208.w,
              child: _StatusDropdown(
                selected: state.filter.status,
                counts: state.statusCounts,
                onSelected: _selectStatus,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _statusPortalController,
      overlayChildBuilder: _buildStatusOverlay,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: _searching
              ? _SearchBar(
                  key: const ValueKey('search'),
                  controller: _controller,
                  focus: _focus,
                  onChanged: _onChanged,
                  onClose: _closeSearch,
                )
              : _TitleBar(
                  key: const ValueKey('title'),
                  statusLayerLink: _statusLayerLink,
                  onSearch: _openSearch,
                  onFilter: _openFilter,
                  onStatus: _toggleStatusDropdown,
                ),
        ),
      ),
    );
  }
}

/// Qidiruv yopiq holati: sarlavha + qidiruv + filtr (nuqtali).
class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.statusLayerLink,
    required this.onSearch,
    required this.onFilter,
    required this.onStatus,
    super.key,
  });

  final LayerLink statusLayerLink;
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  final VoidCallback onStatus;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: l10n.tasksTitle
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
          onTap: onSearch,
        ),
        SizedBox(width: 12.w),
        BlocBuilder<TasksBloc, TasksState>(
          buildWhen: (p, c) =>
              p.filter.hasActiveFilters != c.filter.hasActiveFilters,
          builder: (context, state) => _SquareIconButton(
            icon: Assets.icons.icFilter,
            background: colors.backgroundElevation1,
            size: 40,
            iconSize: 16,
            showDot: state.filter.hasActiveFilters,
            onTap: onFilter,
          ),
        ),
        SizedBox(width: 12.w),
        BlocBuilder<TasksBloc, TasksState>(
          buildWhen: (p, c) =>
              p.filter.status != c.filter.status ||
              p.statusPages != c.statusPages,
          builder: (context, state) => CompositedTransformTarget(
            link: statusLayerLink,
            child: _StatusFilterButton(
              status: state.filter.status,
              count: state.filter.status == null
                  ? null
                  : state.statusCounts[state.filter.status!] ?? 0,
              onTap: onStatus,
            ),
          ),
        ),
      ],
    );
  }
}

String _statusLabel(TaskStatus status, AppLocalizations l10n) =>
    switch (status) {
      TaskStatus.todo => l10n.statTaskTodo,
      TaskStatus.inProgress => l10n.taskStatusInProgress,
      TaskStatus.overdue => l10n.taskStatusOverdue,
      TaskStatus.done => l10n.taskStatusDone,
      TaskStatus.production => l10n.taskStatusProduction,
      TaskStatus.checked => l10n.taskStatusChecked,
      TaskStatus.rejected => l10n.taskStatusRejected,
      TaskStatus.unknown => '',
    };

Color _statusColor(TaskStatus status, AppColors colors) => switch (status) {
  TaskStatus.todo => colors.taskStatusTodo,
  TaskStatus.inProgress => colors.taskStatusInProgress,
  TaskStatus.overdue => colors.taskStatusOverdue,
  TaskStatus.done => colors.taskStatusDone,
  TaskStatus.production => colors.taskStatusProduction,
  TaskStatus.checked => colors.taskStatusChecked,
  TaskStatus.rejected => colors.taskStatusRejected,
  TaskStatus.unknown => colors.textSoft,
};

class _StatusFilterButton extends StatelessWidget {
  const _StatusFilterButton({
    required this.status,
    required this.count,
    required this.onTap,
  });

  final TaskStatus? status;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final selected = status;
    final label = selected == null
        ? l10n.taskFilterStatus
        : _statusLabel(selected, l10n);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          child: SizedBox(
            height: 34.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 94.w),
                  child: label
                      .s(11.sp)
                      .w(800)
                      .h(16 / 11)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                if (selected != null) ...[
                  SizedBox(width: 8.w),
                  _StatusBadge(
                    count: count ?? 0,
                    color: _statusColor(selected, colors),
                  ),
                ],
                SizedBox(width: 8.w),
                Assets.icons.icTuilconChervonDown.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconSub,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final TaskStatus? selected;
  final Map<TaskStatus, int> counts;
  final ValueChanged<TaskStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      type: MaterialType.transparency,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundBase,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final status in taskFilterStatuses) ...[
                _StatusDropdownItem(
                  status: status,
                  count: counts[status] ?? 0,
                  selected: status == selected,
                  onTap: () => onSelected(status),
                ),
                if (status != taskFilterStatuses.last) SizedBox(height: 2.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDropdownItem extends StatelessWidget {
  const _StatusDropdownItem({
    required this.status,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final TaskStatus status;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.backgroundElevation1Alt : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Row(
            children: [
              Expanded(
                child: _statusLabel(status, l10n)
                    .s(13.sp)
                    .w(800)
                    .h(20 / 13)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 8.w),
              _StatusBadge(count: count, color: _statusColor(status, colors)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 6.w),
          child: SizedBox(
            height: 16.h,
            child: Center(
              child: count
                  .toString()
                  .s(11.sp)
                  .w(800)
                  .h(16 / 11)
                  .c(colors.textWhite)
                  .a(TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}

/// Qidiruv ochiq holati: to'liq kenglikdagi qidiruv maydoni + "Yopish".
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.focus,
    required this.onChanged,
    required this.onClose,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: colors.textStrong,
    );

    return Row(
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.strokeSub, width: 1.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: SizedBox(
                height: 40.h,
                child: Row(
                  children: [
                    Assets.icons.icSearch.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focus,
                        onChanged: onChanged,
                        textInputAction: TextInputAction.search,
                        style: style,
                        cursorColor: colors.accentSub,
                        decoration: InputDecoration.collapsed(
                          hintText: l10n.taskSearchHint,
                          hintStyle: style.copyWith(color: colors.textSub),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (context, value, _) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                controller.clear();
                                onChanged('');
                              },
                              borderRadius: BorderRadius.circular(8.r),
                              child: Padding(
                                padding: EdgeInsets.all(4.w),
                                child: Assets.icons.icClose.svg(
                                  width: 14.w,
                                  height: 14.w,
                                  colorFilter: ColorFilter.mode(
                                    colors.iconSub,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(8.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: l10n.taskSearchClose.s(13.sp).w(700).c(colors.textSub),
          ),
        ),
      ],
    );
  }
}

class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.onTap});

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
                Assets.icons.icTaskDaliy.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                l10n.taskAdd.s(13.sp).w(800).c(colors.textWhite),
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
    this.showDot = false,
  });

  final SvgGenImage icon;
  final Color background;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? borderColor;

  /// Faol filtr nishoni — o'ng-yuqorida accent nuqta.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget square = DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor ?? colors.strokeSoft, width: 1.w),
      ),
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: Center(
          child: icon.svg(
            width: iconSize.w,
            height: iconSize.w,
            colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
          ),
        ),
      ),
    );

    if (showDot) {
      square = Stack(
        clipBehavior: Clip.none,
        children: [
          square,
          Positioned(
            top: -2.h,
            right: -2.w,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentSub,
                shape: BoxShape.circle,
                border: Border.all(color: colors.backgroundBase, width: 2.w),
              ),
              child: SizedBox(width: 10.w, height: 10.w),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: square,
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
    final message = failure is NetworkFailure
        ? l10n.networkError
        : l10n.commonError;

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
