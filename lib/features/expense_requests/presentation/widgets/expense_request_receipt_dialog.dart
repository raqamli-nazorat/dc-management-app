import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../l10n/app_localizations.dart';

/// To'lov cheki yuklash dialogi (Figma: node 2796-295936). "To'lov qildim"
/// tasdiq dialogidan keyin ochiladi. Natija:
/// - `null` — bekor qilindi (barrier bosildi), to'lov qilinmaydi;
/// - bo'sh ro'yxat — "O'tkazib yuborish" (cheksiz to'lov);
/// - fayl yo'llari — "Yuborish" (cheklar yuklanib, to'lov qilinadi).
Future<List<String>?> showExpenseRequestReceiptDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<List<String>>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: colors.overlaySurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: const _ReceiptDialog(),
    ),
  );
}

class _ReceiptDialog extends StatefulWidget {
  const _ReceiptDialog();

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  final List<String> _paths = [];

  Future<void> _pick() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.image,
      );
      if (result == null) return;
      setState(() {
        for (final f in result.files) {
          if (f.path != null) _paths.add(f.path!);
        }
      });
    } catch (_) {
      if (!mounted) return;
      AppToast.showError(
        context,
        title: AppLocalizations.of(context).commonError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350.w),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: l10n.expenseRequestReceiptDialogTitle
                      .s(19.sp)
                      .w(800)
                      .h(28 / 19)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
                SizedBox(width: 8.w),
                Tooltip(
                  triggerMode: TooltipTriggerMode.tap,
                  showDuration: const Duration(seconds: 4),
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation2Alt,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: colors.textStrong,
                    fontFamily: 'Manrope',
                  ),
                  message: l10n.expenseRequestReceiptInfo,
                  child: Assets.icons.icAlertCircle.svg(
                    width: 24.w,
                    height: 24.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            l10n.expenseRequestReceiptDialogSubtitle
                .s(15.sp)
                .w(500)
                .h(24 / 15)
                .c(colors.textSub)
                .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
            SizedBox(height: 16.h),
            _ReceiptGrid(
              paths: _paths,
              onAdd: _pick,
              onRemove: (p) => setState(() => _paths.remove(p)),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Flexible(
                  child: _SkipButton(
                    onTap: () => Navigator.of(context).pop(const <String>[]),
                  ),
                ),
                SizedBox(width: 12.w),
                _SendButton(
                  onTap: () => Navigator.of(context).pop([..._paths]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Ikki ustunli chek ko'rinishlari + oxirida "yuklash" plitkasi.
class _ReceiptGrid extends StatelessWidget {
  const _ReceiptGrid({
    required this.paths,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> paths;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final spacing = 12.w;
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final path in paths)
              _ReceiptTile(
                width: tileWidth,
                path: path,
                onRemove: () => onRemove(path),
              ),
            _AddReceiptTile(width: tileWidth, onTap: onAdd),
          ],
        );
      },
    );
  }
}

class _ReceiptTile extends StatelessWidget {
  const _ReceiptTile({
    required this.width,
    required this.path,
    required this.onRemove,
  });

  final double width;
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.file(
            File(path),
            width: width,
            height: 140.h,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(12.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.errorStrong,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 24.w,
                height: 24.w,
                child: Center(
                  child: Assets.icons.icClose.svg(
                    width: 12.w,
                    height: 12.w,
                    colorFilter: ColorFilter.mode(
                      colors.textWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AddReceiptTile extends StatelessWidget {
  const _AddReceiptTile({required this.width, required this.onTap});

  final double width;
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
          color: colors.backgroundElevation1Alt,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: SizedBox(
          width: width,
          height: 140.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Assets.icons.icDocument.svg(
                width: 24.w,
                height: 24.w,
                colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: l10n.expenseRequestReceiptAddTile
                    .s(13.sp)
                    .w(500)
                    .c(colors.textSub)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "→ O'tkazib yuborish" — fonsiz accent-matnli tugma.
class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 14.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.icArrowRight.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(colors.textAccent, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: l10n.expenseRequestReceiptSkip
                  .s(15.sp)
                  .w(800)
                  .h(24 / 15)
                  .c(colors.textAccent)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Yuborish ↗" — to'ldirilgan accent tugma.
class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.accentStrong,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SizedBox(
            height: 52.h,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Assets.icons.icArrowRightExit.svg(
                  width: 20.w,
                  height: 20.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 8.w),
                l10n.expenseRequestReceiptSend
                    .s(15.sp)
                    .w(800)
                    .h(24 / 15)
                    .c(colors.textWhite),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
