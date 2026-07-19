import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../l10n/app_localizations.dart';

/// "To'lov qildim" tasdiq dialogi (Figma: node 1881-316290) — `true` tasdiq,
/// `null`/`false` bekor. Yashil "Tasdiqlash" + check ikonka.
Future<bool?> showExpenseRequestPayDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<bool>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: colors.overlaySurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: const _PayDialog(),
    ),
  );
}

/// "Rad etish" sabab dialogi (Figma: node 1881-316314) — kiritilgan sabab
/// `pop` orqali qaytadi (bo'sh bo'lsa tugma bloklangan), bekor — `null`.
Future<String?> showExpenseRequestCancelDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<String>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      backgroundColor: colors.overlaySurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: const _CancelDialog(),
    ),
  );
}

class _PayDialog extends StatelessWidget {
  const _PayDialog();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return _DialogFrame(
      children: [
        l10n.expenseRequestPayDialogTitle
            .s(19.sp)
            .w(800)
            .h(28 / 19)
            .c(colors.textStrong)
            .a(TextAlign.center)
            .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        SizedBox(height: 4.h),
        l10n.expenseRequestPayDialogSubtitle
            .s(15.sp)
            .w(500)
            .h(24 / 15)
            .c(colors.textSub)
            .a(TextAlign.center)
            .copyWith(maxLines: 3, overflow: TextOverflow.ellipsis),
        SizedBox(height: 24.h),
        Row(
          children: [
            const _DismissButton(),
            SizedBox(width: 12.w),
            Expanded(
              child: _ActionButton(
                label: l10n.payrollConfirmButton,
                color: colors.successStrong,
                icon: Assets.icons.icCheckmarkCircle,
                onTap: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final style = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return _DialogFrame(
      children: [
        l10n.taskRejectSubtitle
            .s(19.sp)
            .w(800)
            .h(28 / 19)
            .c(colors.textStrong)
            .a(TextAlign.center)
            .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
        SizedBox(height: 16.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: TextField(
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              style: style,
              cursorColor: colors.accentSub,
              decoration: InputDecoration.collapsed(
                hintText: l10n.expenseRequestCancelReasonHint,
                hintStyle: style.copyWith(color: colors.textSub),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            const _DismissButton(),
            SizedBox(width: 12.w),
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => _ActionButton(
                  label: l10n.meetingExcuseReject,
                  color: colors.errorStrong,
                  icon: Assets.icons.icClose,
                  onTap: value.text.trim().isEmpty
                      ? null
                      : () => Navigator.of(context).pop(value.text.trim()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Umumiy dialog ramkasi: tepa "tutqich" chizig'i + kontent.
class _DialogFrame extends StatelessWidget {
  const _DialogFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 350.w),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 8.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.strokeSoft,
                borderRadius: BorderRadius.circular(1.r),
              ),
              child: SizedBox(width: 24.w, height: 3.h),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ],
      ),
    );
  }
}

/// "✕ Bekor qilish" — fonsiz chap tugma.
class _DismissButton extends StatelessWidget {
  const _DismissButton();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: () => Navigator.of(context).pop(),
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: SizedBox(
          height: 52.h,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Assets.icons.icClose.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(
                  colors.textStrong,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: 8.w),
              l10n.taskDeleteCancel
                  .s(15.sp)
                  .w(800)
                  .h(24 / 15)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rangli asosiy tugma (ikonka + yorliq). `onTap == null` — bloklangan.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final SvgGenImage icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Opacity(
      opacity: onTap == null ? 0.5 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SizedBox(
            height: 52.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.svg(
                  width: 16.w,
                  height: 16.w,
                  colorFilter: ColorFilter.mode(
                    colors.textWhite,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 4.w),
                Flexible(
                  child: label
                      .s(15.sp)
                      .w(800)
                      .h(24 / 15)
                      .c(colors.textWhite)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
