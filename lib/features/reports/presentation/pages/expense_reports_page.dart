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
import '../../domain/entities/expense_report_filter.dart';
import '../bloc/expense_reports_bloc.dart';
import '../widgets/expense_report_card.dart';

class ExpenseReportsPage extends StatelessWidget {
  const ExpenseReportsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        getIt<ExpenseReportsBloc>()..add(const ExpenseReportsRequested()),
    child: const _ExpenseReportsView(),
  );
}

class _ExpenseReportsView extends StatefulWidget {
  const _ExpenseReportsView();
  @override
  State<_ExpenseReportsView> createState() => _ExpenseReportsViewState();
}

class _ExpenseReportsViewState extends State<_ExpenseReportsView> {
  final _scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<ExpenseReportsBloc>().add(const ExpenseReportsLoadMore());
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final bloc = context.read<ExpenseReportsBloc>();
    bloc.add(const ExpenseReportsRequested());
    return bloc.stream.firstWhere(
      (state) => state.status != ExpenseReportsStatus.loading,
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
            const _Header(),
            Expanded(
              child: RefreshIndicator(
                color: colors.accentSub,
                onRefresh: _refresh,
                child: BlocBuilder<ExpenseReportsBloc, ExpenseReportsState>(
                  builder: (context, state) => switch (state.status) {
                    ExpenseReportsStatus.initial ||
                    ExpenseReportsStatus.loading => const _ScrollableCenter(
                      child: CircularProgressIndicator(),
                    ),
                    ExpenseReportsStatus.failure => _ScrollableCenter(
                      child: _Error(failure: state.failure),
                    ),
                    ExpenseReportsStatus.success =>
                      state.items.isEmpty
                          ? _ScrollableCenter(
                              child: AppLocalizations.of(context)
                                  .expenseReportsEmpty
                                  .s(14.sp)
                                  .w(500)
                                  .c(colors.textSub),
                            )
                          : ListView.separated(
                              controller: _scroll,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(
                                20.w,
                                12.h,
                                20.w,
                                24.h,
                              ),
                              itemCount:
                                  state.items.length +
                                  (state.hasReachedMax ? 0 : 1),
                              separatorBuilder: (_, _) => SizedBox(height: 8.h),
                              itemBuilder: (_, index) =>
                                  index >= state.items.length
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 16.h,
                                      ),
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
                                    )
                                  : ExpenseReportCard(
                                      report: state.items[index],
                                    ),
                            ),
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

class _Header extends StatefulWidget {
  const _Header();
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
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

  void _search() {
    setState(() => _searching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _close() {
    _debounce?.cancel();
    final hasText = _controller.text.isNotEmpty;
    _controller.clear();
    _focus.unfocus();
    setState(() => _searching = false);
    if (hasText) {
      context.read<ExpenseReportsBloc>().add(
        const ExpenseReportsSearchChanged(''),
      );
    }
  }

  void _changed(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        context.read<ExpenseReportsBloc>().add(
          ExpenseReportsSearchChanged(value.trim()),
        );
      }
    });
  }

  Future<void> _filter() async {
    final bloc = context.read<ExpenseReportsBloc>();
    final result = await context.pushNamed<Object?>(
      Routes.expenseReportsFilter.name,
      extra: bloc.state.filter,
    );
    if (result is ExpenseReportFilter) {
      bloc.add(ExpenseReportsFilterChanged(result));
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
    child: AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _searching
          ? _SearchBar(
              key: const ValueKey('search'),
              controller: _controller,
              focus: _focus,
              onChanged: _changed,
              onClose: _close,
            )
          : _TitleBar(
              key: const ValueKey('title'),
              onSearch: _search,
              onFilter: _filter,
            ),
    ),
  );
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.onSearch, required this.onFilter, super.key});
  final VoidCallback onSearch;
  final VoidCallback onFilter;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
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
          child: AppLocalizations.of(context).reportSpendingRequests
              .s(17.sp)
              .w(800)
              .c(colors.textStrong)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 12.w),
        _IconButton(icon: Assets.icons.icSearch, onTap: onSearch),
        SizedBox(width: 12.w),
        BlocBuilder<ExpenseReportsBloc, ExpenseReportsState>(
          buildWhen: (a, b) =>
              a.filter.hasActiveFilters != b.filter.hasActiveFilters,
          builder: (_, state) => _IconButton(
            icon: Assets.icons.icFilter,
            onTap: onFilter,
            dot: state.filter.hasActiveFilters,
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
                          hintText: l10n.taskSearchHint,
                          hintStyle: style.copyWith(color: colors.textSub),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (_, value, _) => value.text.isEmpty
                          ? const SizedBox.shrink()
                          : InkWell(
                              onTap: () {
                                controller.clear();
                                onChanged('');
                              },
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
            child: l10n.taskSearchClose.s(13.sp).w(700).c(colors.textSub),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    this.dot = false,
  });
  final SvgGenImage icon;
  final VoidCallback onTap;
  final bool dot;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final button = DecoratedBox(
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: dot
          ? Badge(
              backgroundColor: colors.accentSub,
              smallSize: 8.w,
              child: button,
            )
          : button,
    );
  }
}

class _ScrollableCenter extends StatelessWidget {
  const _ScrollableCenter({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, box) => ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: box.maxHeight,
          child: Center(child: child),
        ),
      ],
    ),
  );
}

class _Error extends StatelessWidget {
  const _Error({required this.failure});
  final Failure? failure;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        (failure is NetworkFailure ? l10n.networkError : l10n.commonError)
            .s(14.sp)
            .w(500)
            .c(colors.textSub),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => context.read<ExpenseReportsBloc>().add(
            const ExpenseReportsRequested(),
          ),
          child: l10n.commonRetry.s(14.sp).w(600).c(colors.textAccent),
        ),
      ],
    );
  }
}
