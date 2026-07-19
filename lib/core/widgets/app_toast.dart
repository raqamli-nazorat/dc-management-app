import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';
import '../gen/assets.gen.dart';

/// Ilova bo'ylab qayta ishlatiladigan toast bildirishnomasi — ekranning
/// tepasidan sirg'alib chiqadi, o'zi yopiladi yoki qo'lda yopiladi.
///
/// Foydalanish: `AppToast.showSuccess(context, title: ..., message: ...)`.
/// Overlay orqali chiziladi — chaqiruvchi widget yo'q bo'lib ketsa ham
/// (masalan dialog yopilsa) toast qoladi (root overlay'ga qo'yiladi).
enum _ToastVariant { success, error }

abstract final class AppToast {
  /// Muvaffaqiyat toasti (yashil check ikonka bilan). [message] ixtiyoriy —
  /// bo‘lmasa faqat sarlavha ko‘rsatiladi.
  static void showSuccess(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 3),
  }) => _show(context, _ToastVariant.success, title, message, duration);

  /// Xato toasti (qizil ogohlantirish ikonka bilan). Backenddan kelgan
  /// validatsiya xabarlarini ko‘rsatish uchun.
  static void showError(
    BuildContext context, {
    required String title,
    String? message,
    Duration duration = const Duration(seconds: 4),
  }) => _show(context, _ToastVariant.error, title, message, duration);

  static void _show(
    BuildContext context,
    _ToastVariant variant,
    String title,
    String? message,
    Duration duration,
  ) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastCard(
        variant: variant,
        title: title,
        message: message,
        duration: duration,
        onDismissed: () {
          if (entry.mounted) entry.remove();
        },
      ),
    );
    overlay.insert(entry);
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({
    required this.variant,
    required this.title,
    required this.message,
    required this.duration,
    required this.onDismissed,
  });

  final _ToastVariant variant;
  final String title;
  final String? message;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  Timer? _autoDismiss;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _autoDismiss = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _autoDismiss?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isError = widget.variant == _ToastVariant.error;
    final icon = isError
        ? Assets.icons.icAlertCircle
        : Assets.icons.icCheckCircle;
    final iconColor = isError ? colors.errorStrong : colors.successStrong;

    return Positioned(
      top: MediaQuery.paddingOf(context).top + 8.h,
      left: 16.w,
      right: 16.w,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            type: MaterialType.transparency,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.overlaySurface,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: colors.strokeSub, width: 1.w),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 16.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15.h, right: 12.w),
                      child: icon.svg(
                        width: 16.w,
                        height: 16.w,
                        colorFilter: ColorFilter.mode(
                          iconColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            widget.title
                                .s(15.sp)
                                .w(800)
                                .c(colors.textStrong)
                                .copyWith(
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            if (widget.message != null &&
                                widget.message!.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              widget.message!
                                  .s(13.sp)
                                  .w(500)
                                  .c(colors.textSub)
                                  .copyWith(
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _dismiss,
                      borderRadius: BorderRadius.circular(12.r),
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 10.w,
                          right: 10.w,
                          top: 8.h,
                          bottom: 8.h,
                        ),
                        child: Assets.icons.icClose.svg(
                          width: 24.w,
                          height: 24.w,
                          colorFilter: ColorFilter.mode(
                            colors.iconSub,
                            BlendMode.srcIn,
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
      ),
    );
  }
}
