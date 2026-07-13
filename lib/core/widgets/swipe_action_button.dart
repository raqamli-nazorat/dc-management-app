import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../extentions/text_extensions.dart';

/// Figma pill action: status faqat handle threshold'ga yetib, swipe tugagach
/// [onCompleted] orqali o'zgaradi.
class SwipeActionButton extends StatefulWidget {
  const SwipeActionButton({
    super.key,
    required this.label,
    required this.onCompleted,
    required this.trackColor,
    required this.handleColor,
    required this.icon,
    this.fillGradient,
    this.resetAfterComplete = true,
    this.enabled = true,
    this.height = 52,
    this.handleSize = 48,
    this.handleInset = 2,
    this.handleOnRight = false,
    this.completeThreshold = .85,
  });

  final String label;
  final VoidCallback onCompleted;
  final Color trackColor;
  final Color handleColor;
  final Widget icon;
  final Gradient? fillGradient;
  final bool resetAfterComplete;
  final bool enabled;
  final double height;
  final double handleSize;
  final double handleInset;
  final bool handleOnRight;
  final double completeThreshold;

  @override
  State<SwipeActionButton> createState() => _SwipeActionButtonState();
}

class _SwipeActionButtonState extends State<SwipeActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _maxDrag = 1;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SwipeActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.enabled && widget.enabled) {
      _completed = false;
      _controller.value = 0;
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled || _completed) return;
    final delta = (details.primaryDelta ?? 0) / _maxDrag;
    _controller.value += widget.handleOnRight ? -delta : delta;
  }

  Future<void> _onDragEnd(DragEndDetails details) async {
    if (!widget.enabled || _completed) return;
    if (_controller.value < widget.completeThreshold) {
      await _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutBack,
      );
      return;
    }

    _completed = true;
    await _controller.animateTo(
      1,
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
    );
    if (mounted) widget.onCompleted();
    if (widget.resetAfterComplete && mounted) {
      await Future<void>.delayed(const Duration(milliseconds: 240));
      if (!mounted) return;
      await _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
      _completed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final height = widget.height.h;
    final handleSize = widget.handleSize.h;
    final inset = widget.handleInset.h;
    final radius = BorderRadius.circular(24.r);

    return LayoutBuilder(
      builder: (context, constraints) {
        _maxDrag = (constraints.maxWidth - handleSize - inset * 2).clamp(
          1.0,
          double.infinity,
        );

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final progress = _controller.value;
            final fillWidth = progress * _maxDrag;
            final handleLeft = widget.handleOnRight
                ? inset + _maxDrag - fillWidth
                : inset + fillWidth;
            final fill = widget.fillGradient == null
                ? BoxDecoration(
                    color: widget.handleColor.withValues(alpha: .18),
                    borderRadius: radius,
                  )
                : BoxDecoration(
                    gradient: widget.fillGradient,
                    borderRadius: radius,
                  );

            return DecoratedBox(
              decoration: BoxDecoration(
                color: widget.trackColor,
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow,
                    blurRadius: 3.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: SizedBox(
                height: height,
                child: ClipRRect(
                  borderRadius: radius,
                  child: Stack(
                    children: [
                      Positioned(
                        left: widget.handleOnRight ? null : 0,
                        right: widget.handleOnRight ? 0 : null,
                        top: 0,
                        bottom: 0,
                        width: fillWidth.clamp(0.0, constraints.maxWidth),
                        child: DecoratedBox(decoration: fill),
                      ),
                      Positioned.fill(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 60.w),
                            child: widget.label
                                .s(15.sp)
                                .w(800)
                                .h(24 / 15)
                                .c(colors.textSub)
                                .copyWith(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: handleLeft,
                        top: inset,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onHorizontalDragUpdate: _onDragUpdate,
                          onHorizontalDragEnd: _onDragEnd,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: widget.handleColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow,
                                  blurRadius: 6.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              width: handleSize,
                              height: handleSize,
                              child: Center(child: widget.icon),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
