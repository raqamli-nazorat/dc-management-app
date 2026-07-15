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
import '../../domain/entities/user_report_filter.dart';
import '../bloc/user_reports_bloc.dart';
import '../widgets/user_report_card.dart';

/// Xodimlar bo'yicha hisobot ro'yxati ekrani (`GET /reports/users/`).
class UserReportsPage extends StatelessWidget {
  const UserReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserReportsBloc>(
      create: (_) =>
          getIt<UserReportsBloc>()..add(const UserReportsRequested()),
      child: const _UserReportsView(),
    );
  }
}

class _UserReportsView extends StatefulWidget {
  const _UserReportsView();

  @override
  State<_UserReportsView> createState() => _UserReportsViewState();
}

class _UserReportsViewState extends State<_UserReportsView> {
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
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<UserReportsBloc>().add(const UserReportsLoadMore());
    }
  }

  Future<void> _onRefresh(BuildContext context) {
    final bloc = context.read<UserReportsBloc>();
    bloc.add(const UserReportsRequested());
    return bloc.stream.firstWhere((s) => s.status != UserReportsStatus.loading);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            const _ReportsHeader(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: () => _onRefresh(context),
                child: BlocBuilder<UserReportsBloc, UserReportsState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case UserReportsStatus.loading:
                      case UserReportsStatus.initial:
                        return const _CenteredScrollable(
                          child: CircularProgressIndicator(),
                        );
                      case UserReportsStatus.failure:
                        return _CenteredScrollable(
                          child: _ErrorState(
                            failure: state.failure,
                            onRetry: () => context.read<UserReportsBloc>().add(
                              const UserReportsRequested(),
                            ),
                          ),
                        );
                      case UserReportsStatus.success:
                        if (state.items.isEmpty) {
                          return _CenteredScrollable(
                            child: AppLocalizations.of(context)
                                .reportsEmployeeEmpty
                                .s(14.sp)
                                .w(500)
                                .c(colors.textSub),
                          );
                        }
                        return ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                          itemCount:
                              state.items.length +
                              (state.hasReachedMax ? 0 : 1),
                          separatorBuilder: (_, _) => SizedBox(height: 8.h),
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
                            return UserReportCard(report: state.items[i]);
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

/// Sarlavha: orqaga + "Xodim bo'yicha" + qidiruv + filtr (filtr — stub,
/// hozircha sahifasi yo'q).
/// Sarlavha qatori: orqaga + "Xodim bo'yicha" + qidiruv + filtr. Qidiruv
/// ikonkasi bosilganda butun qator to'liq kenglikdagi qidiruv maydoniga
/// almashadi (vazifalar sahifasidagi naqsh bilan bir xil).
class _ReportsHeader extends StatefulWidget {
  const _ReportsHeader();

  @override
  State<_ReportsHeader> createState() => _ReportsHeaderState();
}

class _ReportsHeaderState extends State<_ReportsHeader> {
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
    // Maydon animatsiyada quriladi — keyingi kadrda fokus so'raymiz.
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _closeSearch() {
    _debounce?.cancel();
    final hadText = _controller.text.isNotEmpty;
    _controller.clear();
    _focus.unfocus();
    setState(() => _searching = false);
    if (hadText) {
      context.read<UserReportsBloc>().add(const UserReportsSearchChanged(''));
    }
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<UserReportsBloc>().add(
          UserReportsSearchChanged(value.trim()),
        );
      }
    });
  }

  Future<void> _openFilter() async {
    final bloc = context.read<UserReportsBloc>();
    final result = await context.pushNamed<Object?>(
      Routes.userReportsFilter.name,
      extra: bloc.state.filter,
    );
    if (result is UserReportFilter) {
      bloc.add(UserReportsFilterChanged(result));
    }
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
                onFilter: _openFilter,
              ),
      ),
    );
  }
}

/// Qidiruv yopiq holati: orqaga + sarlavha + qidiruv + filtr (nuqtali).
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
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Assets.icons.icArrowLeftLarge.svg(
              width: 24.w,
              height: 24.w,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: l10n.reportEmployee
              .s(17.sp)
              .w(800)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 12.w),
        _SquareIconButton(icon: Assets.icons.icSearch, onTap: onSearch),
        SizedBox(width: 12.w),
        BlocBuilder<UserReportsBloc, UserReportsState>(
          buildWhen: (p, c) =>
              p.filter.hasActiveFilters != c.filter.hasActiveFilters,
          builder: (context, state) => _SquareIconButton(
            icon: Assets.icons.icFilter,
            showDot: state.filter.hasActiveFilters,
            onTap: onFilter,
          ),
        ),
      ],
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

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final SvgGenImage icon;
  final VoidCallback onTap;

  /// Faol filtr nishoni — o'ng-yuqorida accent nuqta.
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    Widget square = DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.strokeSoft, width: 1.w),
      ),
      child: SizedBox(
        width: 40.w,
        height: 40.w,
        child: Center(
          child: icon.svg(
            width: 16.w,
            height: 16.w,
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
