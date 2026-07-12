import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

class AppFilterHeader extends StatelessWidget {
  const AppFilterHeader({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
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
            child: title
                .s(17.sp)
                .w(800)
                .h(28 / 17)
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

class AppFilterFieldLabel extends StatelessWidget {
  const AppFilterFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w, bottom: 4.h),
      child: text.s(11.sp).w(500).h(16 / 11).c(AppColors.of(context).textSub),
    );
  }
}

BoxDecoration appFilterFieldDecoration(AppColors colors) => BoxDecoration(
  color: colors.backgroundBase,
  borderRadius: BorderRadius.circular(12.r),
  border: Border.all(color: colors.strokeSub, width: 1.w),
);

class AppFilterFieldBox extends StatelessWidget {
  const AppFilterFieldBox({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.onTap,
    required this.onClear,
    this.showClear = true,
    this.link,
    this.chevron,
    super.key,
  });

  final String label;
  final String? value;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final bool showClear;
  final LayerLink? link;
  final SvgGenImage? chevron;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    Widget box = DecoratedBox(
      decoration: appFilterFieldDecoration(colors),
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, right: hasValue ? 6.w : 12.w),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              Expanded(
                child: (hasValue ? value! : placeholder)
                    .s(13.sp)
                    .w(500)
                    .h(20 / 13)
                    .c(hasValue ? colors.textStrong : colors.textSub)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              SizedBox(width: 4.w),
              if (hasValue && showClear)
                InkWell(
                  onTap: onClear,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Assets.icons.icClose.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                )
              else if (!hasValue)
                (chevron ?? Assets.icons.icTuilconChervonDown).svg(
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
    );
    if (link != null) {
      box = CompositedTransformTarget(link: link!, child: box);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: box,
        ),
      ],
    );
  }
}

class AppFilterPickerBox extends StatelessWidget {
  const AppFilterPickerBox({
    required this.value,
    required this.placeholder,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String value;
  final String placeholder;
  final SvgGenImage icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = value.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: appFilterFieldDecoration(colors),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: SizedBox(
            height: 44.h,
            child: Row(
              children: [
                Expanded(
                  child: (hasValue ? value : placeholder)
                      .s(13.sp)
                      .w(500)
                      .h(20 / 13)
                      .c(hasValue ? colors.textStrong : colors.textSub)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 4.w),
                icon.svg(
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

class AppFilterDropdownBox extends StatelessWidget {
  const AppFilterDropdownBox({
    required this.children,
    required this.emptyText,
    super.key,
  });

  final List<Widget> children;
  final String emptyText;

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
          child: children.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Center(
                    child: emptyText.s(13.sp).w(500).c(colors.textSub),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: children,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class AppFilterDropdownItem extends StatelessWidget {
  const AppFilterDropdownItem({
    required this.selected,
    required this.onTap,
    required this.child,
    this.height,
    this.verticalPadding,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final double? height;
  final double? verticalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final content = height == null
        ? child
        : SizedBox(
            height: height!.h,
            child: Center(child: child),
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? colors.backgroundElevation1Alt : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: (verticalPadding ?? 0).h,
          ),
          child: content,
        ),
      ),
    );
  }
}

class AppFilterActionBar extends StatelessWidget {
  const AppFilterActionBar({
    required this.resetLabel,
    required this.applyLabel,
    required this.onReset,
    required this.onApply,
    super.key,
  });

  final String resetLabel;
  final String applyLabel;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: onReset,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation1Alt,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.icClose.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconStrong,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        resetLabel
                            .s(15.sp)
                            .w(800)
                            .h(24 / 15)
                            .c(colors.textStrong),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: InkWell(
                onTap: onApply,
                borderRadius: BorderRadius.circular(16.r),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.accentStrong,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox(
                    height: 52.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.icons.icSearch.svg(
                          width: 16.w,
                          height: 16.w,
                          colorFilter: ColorFilter.mode(
                            colors.textWhite,
                            BlendMode.srcIn,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        applyLabel
                            .s(15.sp)
                            .w(800)
                            .h(24 / 15)
                            .c(colors.textWhite),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
