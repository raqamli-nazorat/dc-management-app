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
import '../../domain/entities/project.dart';
import '../bloc/projects_bloc.dart';
import '../widgets/project_card.dart';

class ProjectsListPage extends StatelessWidget {
  const ProjectsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProjectsBloc>(
      create: (_) => getIt<ProjectsBloc>()..add(const ProjectsRequested()),
      child: const _ProjectsListView(),
    );
  }
}

class _ProjectsListView extends StatefulWidget {
  const _ProjectsListView();

  @override
  State<_ProjectsListView> createState() => _ProjectsListViewState();
}

class _ProjectsListViewState extends State<_ProjectsListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300.h) {
      context.read<ProjectsBloc>().add(const ProjectsLoadMore());
    }
  }

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<ProjectsBloc>();
    bloc.add(const ProjectsRequested());
    return bloc.stream.firstWhere(
      (state) => state.status != ProjectsStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _ProjectsHeader(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: () => _onRefresh(context),
                child: BlocBuilder<ProjectsBloc, ProjectsState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case ProjectsStatus.initial:
                      case ProjectsStatus.loading:
                        return const _CenteredScrollable(
                          child: CircularProgressIndicator(),
                        );
                      case ProjectsStatus.failure:
                        return _CenteredScrollable(
                          child: _ErrorState(
                            failure: state.failure,
                            onRetry: () => context.read<ProjectsBloc>().add(
                              const ProjectsRequested(),
                            ),
                          ),
                        );
                      case ProjectsStatus.success:
                        if (state.items.isEmpty) {
                          return _CenteredScrollable(
                            child: AppLocalizations.of(
                              context,
                            ).projectsEmpty.s(14.sp).w(500).c(colors.textSub),
                          );
                        }
                        return ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          itemCount:
                              state.items.length +
                              (state.hasReachedMax ? 0 : 1),
                          separatorBuilder: (_, _) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
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
                            final project = state.items[index];
                            return ProjectCard(
                              project: project,
                              onDelete: () => context.read<ProjectsBloc>().add(
                                ProjectDeleted(project.id),
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

class _ProjectsHeader extends StatelessWidget {
  const _ProjectsHeader();

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
              const _AddProjectButton(),
              SizedBox(width: 12.w),
              _SquareIconButton(
                icon: Assets.icons.icProfileNotification,
                size: 36,
                iconSize: 20,
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

class _SearchFilterRow extends StatefulWidget {
  const _SearchFilterRow();

  @override
  State<_SearchFilterRow> createState() => _SearchFilterRowState();
}

class _SearchFilterRowState extends State<_SearchFilterRow> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
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
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _closeSearch() {
    _debounce?.cancel();
    final hadText = _controller.text.isNotEmpty;
    _controller.clear();
    _focus.unfocus();
    setState(() => _searching = false);
    if (hadText) {
      context.read<ProjectsBloc>().add(const ProjectsSearchChanged(''));
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<ProjectsBloc>().add(ProjectsSearchChanged(value.trim()));
      }
    });
  }

  void _cycleStatus() {
    final bloc = context.read<ProjectsBloc>();
    final statuses = <ProjectStatus?>[
      null,
      ProjectStatus.active,
      ProjectStatus.planning,
      ProjectStatus.overdue,
      ProjectStatus.completed,
      ProjectStatus.cancelled,
    ];
    final index = statuses.indexOf(bloc.state.filter.status);
    bloc.add(ProjectsStatusChanged(statuses[(index + 1) % statuses.length]));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                onSearch: _openSearch,
                onFilter: _cycleStatus,
              ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.onSearch, required this.onFilter, super.key});

  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: l10n.projectsTitle
              .s(17.sp)
              .w(800)
              .h(28 / 17)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 12.w),
        _SquareIconButton(
          icon: Assets.icons.icSearch,
          size: 40,
          iconSize: 16,
          background: colors.backgroundElevation1,
          onTap: onSearch,
        ),
        SizedBox(width: 12.w),
        BlocBuilder<ProjectsBloc, ProjectsState>(
          buildWhen: (previous, current) =>
              previous.filter.status != current.filter.status,
          builder: (context, state) => _SquareIconButton(
            icon: Assets.icons.icFilter,
            size: 40,
            iconSize: 16,
            background: colors.backgroundElevation1,
            showDot: state.filter.status != null,
            onTap: onFilter,
          ),
        ),
      ],
    );
  }
}

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
                          hintText: l10n.projectSearchHint,
                          hintStyle: style.copyWith(color: colors.textSub),
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

class _AddProjectButton extends StatelessWidget {
  const _AddProjectButton();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
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
              Assets.icons.icPlus.svg(
                width: 20.w,
                height: 20.w,
                colorFilter: ColorFilter.mode(
                  colors.textWhite,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              l10n.projectAdd
                  .s(13.sp)
                  .w(800)
                  .c(colors.textWhite)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
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
    required this.size,
    required this.iconSize,
    this.borderColor,
    this.showDot = false,
  });

  final SvgGenImage icon;
  final Color background;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final Color? borderColor;
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        message.s(14.sp).w(500).c(colors.textSub).a(TextAlign.center),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: onRetry,
          child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
        ),
      ],
    );
  }
}
