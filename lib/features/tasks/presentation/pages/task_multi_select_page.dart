import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';

/// Ko'p-tanlov ro'yxatidagi bitta element (loyiha yoki foydalanuvchi).
class MultiSelectItem {
  const MultiSelectItem({
    required this.id,
    required this.initial,
    required this.title,
    this.subtitle = '',
    this.trailing = '',
  });

  final int id;

  /// Avatar bosh harfi (loyiha nomi / F.I.O).
  final String initial;
  final String title;
  final String subtitle;

  /// O'ngdagi qo'shimcha yozuv (loyiha muddati) — bo'sh bo'lsa ko'rsatilmaydi.
  final String trailing;
}

/// [TaskMultiSelectPage] argumentlari (`extra` orqali uzatiladi).
class TaskMultiSelectArgs {
  const TaskMultiSelectArgs({
    required this.title,
    required this.items,
    required this.selected,
  });

  final String title;
  final List<MultiSelectItem> items;
  final Set<int> selected;
}

/// Umumiy ko'p-tanlov sahifasi (Loyiha / Muallif / Xodim tanlash — filtr uchun).
/// Tanlangan id'lar to'plamini `pop` orqali qaytaradi; orqaga tugmasi —
/// bekor (o'zgarishsiz `null`).
class TaskMultiSelectPage extends StatefulWidget {
  const TaskMultiSelectPage({required this.args, super.key});

  final TaskMultiSelectArgs args;

  @override
  State<TaskMultiSelectPage> createState() => _TaskMultiSelectPageState();
}

class _TaskMultiSelectPageState extends State<TaskMultiSelectPage> {
  late final Set<int> _selected = {...widget.args.selected};

  void _toggle(int id) => setState(
    () => _selected.contains(id) ? _selected.remove(id) : _selected.add(id),
  );

  void _confirm() => Navigator.of(context).pop(_selected);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final items = widget.args.items;

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            _Header(title: widget.args.title, onConfirm: _confirm),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: l10n.statEmpty.s(14.sp).w(500).c(colors.textSub),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => SizedBox(height: 8.h),
                      itemBuilder: (_, i) => _SelectableRow(
                        item: items[i],
                        selected: _selected.contains(items[i].id),
                        onTap: () => _toggle(items[i].id),
                      ),
                    ),
            ),
            _ConfirmBar(label: l10n.taskFilterSelectAdd, onTap: _confirm),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onConfirm});

  final String title;
  final VoidCallback onConfirm;

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
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: onConfirm,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Assets.icons.icTuilconCheck.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.iconStrong,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bitta tanlanadigan qator: checkbox + avatar + nom/tavsif + (muddat).
class _SelectableRow extends StatelessWidget {
  const _SelectableRow({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MultiSelectItem item;
  final bool selected;
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
          border: Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              _Checkbox(checked: selected),
              SizedBox(width: 12.w),
              TuiAvatar(initial: item.initial, size: 24),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    item.title
                        .s(13.sp)
                        .w(700)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (item.subtitle.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      item.subtitle
                          .s(11.sp)
                          .w(500)
                          .c(colors.textSoft)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ],
                  ],
                ),
              ),
              if (item.trailing.isNotEmpty) ...[
                SizedBox(width: 8.w),
                item.trailing.s(11.sp).w(500).c(colors.textSub),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tanlash katakchasi: tanlanmagan — chegara + fon; tanlangan — accent + oq belgi.
class _Checkbox extends StatelessWidget {
  const _Checkbox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: checked ? colors.accentStrong : colors.backgroundElevation3Alt,
        borderRadius: BorderRadius.circular(6.r),
        border: checked
            ? null
            : Border.all(color: colors.strokeStrong, width: 1.w),
      ),
      child: SizedBox(
        width: 20.w,
        height: 20.w,
        child: checked
            ? Center(
                child: Assets.icons.icTuilconCheck.svg(
                  width: 12.w,
                  height: 12.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

/// Pastki "Qo'shish" tugmasi (tanlashni tasdiqlaydi).
class _ConfirmBar extends StatelessWidget {
  const _ConfirmBar({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: SizedBox(
              height: 52.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.icUserGroup.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  label.s(15.sp).w(800).c(colors.textStrong),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
