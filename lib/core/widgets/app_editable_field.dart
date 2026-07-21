import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/theme/app_colors.dart';
import '../gen/assets.gen.dart';
import 'app_filter_components.dart';

/// Detail sahifasidagi boxed field ko'rinishidagi tahrirlanuvchi maydon.
class AppEditableField extends StatefulWidget {
  const AppEditableField({
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixText,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.validator,
    this.showLabel = true,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final String? prefixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final bool showObscureToggle;
  final String? Function(String?)? validator;
  final bool showLabel;

  @override
  State<AppEditableField> createState() => _AppEditableFieldState();
}

class _AppEditableFieldState extends State<AppEditableField> {
  final _focusNode = FocusNode();
  late bool _obscured = widget.obscureText;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final textStyle = TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w500,
      height: 20 / 13,
      color: colors.textStrong,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel) AppFilterFieldLabel(widget.label),
        Focus(
          onFocusChange: (_) => setState(() {}),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundBase,
              border: Border.all(
                color: _focusNode.hasFocus
                    ? colors.strokeAccent
                    : colors.strokeSub,
                width: _focusNode.hasFocus ? 1.5.w : 1.w,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 44.h,
                child: Center(
                  child: TextFormField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    inputFormatters: widget.inputFormatters,
                    maxLength: widget.maxLength,
                    obscureText: _obscured,
                    maxLines: 1,
                    validator: widget.validator,
                    style: textStyle,
                    textAlignVertical: TextAlignVertical.center,
                    cursorColor: colors.accentSub,
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      hintText: widget.hintText,
                      hintStyle: textStyle.copyWith(color: colors.textSub),
                      prefixIcon: _prefix(textStyle),
                      prefixIconConstraints: const BoxConstraints(),
                      contentPadding: EdgeInsets.zero,
                      counterText: '',
                      suffixIcon: _obscureToggle(colors),
                      suffixIconConstraints: BoxConstraints(
                        minWidth: 28.w,
                        minHeight: 28.w,
                      ),
                    ),
                    scrollPadding: EdgeInsets.only(bottom: 80.h),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant AppEditableField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscured = widget.obscureText;
    }
  }

  Widget? _obscureToggle(AppColors colors) {
    if (!widget.showObscureToggle || !widget.obscureText) return null;
    return IconButton(
      onPressed: () => setState(() => _obscured = !_obscured),
      icon: (_obscured ? Assets.icons.icEyeOpen : Assets.icons.icEyeClose).svg(
        width: 18.w,
        height: 18.w,
        colorFilter: ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
      ),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(minWidth: 28.w, minHeight: 28.w),
    );
  }

  Widget? _prefix(TextStyle textStyle) {
    if (widget.prefixText == null) return null;
    return Align(
      widthFactor: 1,
      heightFactor: 1,
      child: Padding(
        padding: EdgeInsets.only(right: 4.w),
        child: Text(widget.prefixText!, style: textStyle),
      ),
    );
  }
}
