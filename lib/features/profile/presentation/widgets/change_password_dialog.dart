import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/change_password_bloc.dart';

/// Parolni almashtirish dialogi — eski / yangi / tasdiq parol maydonlari +
/// yuborish. Xato holatlari maydon darajasida ko'rsatiladi: eski parol
/// noto'g'ri bo'lsa (backend javobi) — shu maydon ostida; yangi/tasdiq mos
/// kelmasa (lokal tekshiruv) — tasdiq maydoni ostida. Muvaffaqiyatda dialog
/// yopilib muvaffaqiyat toasti ko'rsatiladi.
///
/// Ko'rsatish uchun [showChangePasswordDialog]dan foydalaning.
class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  /// Backend "eski parol noto'g'ri" deb qaytargan so'nggi urinishning eski
  /// parol qiymati — foydalanuvchi shu maydonni qayta tahrirlasa xato
  /// yo'qoladi (eski, allaqachon tuzatilgan xatoni ko'rsatib turmaslik uchun).
  String? _oldPasswordErrorFor;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool get _mismatch =>
      _confirmController.text.isNotEmpty &&
      _confirmController.text != _newController.text;

  bool get _canSubmit =>
      _oldController.text.isNotEmpty &&
      _newController.text.isNotEmpty &&
      _confirmController.text.isNotEmpty &&
      !_mismatch;

  void _submit(BuildContext context) {
    if (!_canSubmit) return;
    context.read<ChangePasswordBloc>().add(
          ChangePasswordSubmitted(
            oldPassword: _oldController.text,
            newPassword: _newController.text,
            confirmNewPassword: _confirmController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.backgroundBase,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: BlocConsumer<ChangePasswordBloc, ChangePasswordState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          final l10n = AppLocalizations.of(context);
          if (state.status == ChangePasswordStatus.success) {
            Navigator.of(context).pop();
            AppToast.showSuccess(context, title: l10n.changePasswordSuccess);
          } else if (state.status == ChangePasswordStatus.failure) {
            if (state.failure is UnauthorizedFailure) {
              // Maydon ostida ko'rsatiladi — toast shart emas.
              setState(() => _oldPasswordErrorFor = _oldController.text);
              return;
            }
            // Backenddan kelgan aniq xato (masalan "Parol kamida 4 ta
            // raqamdan iborat bo'lishi kerak") toastda ko'rsatiladi.
            final failure = state.failure;
            final message = failure is NetworkFailure
                ? l10n.networkError
                : (failure?.message.isNotEmpty ?? false)
                    ? failure!.message
                    : l10n.commonError;
            AppToast.showError(context, title: message);
          }
        },
        builder: (context, state) {
          final l10n = AppLocalizations.of(context);
          final submitting = state.isLoading;
          final oldError = _oldPasswordErrorFor == _oldController.text
              ? l10n.changePasswordErrorOldWrong
              : null;
          final confirmError = _mismatch ? l10n.changePasswordErrorMismatch : null;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.strokeSoft,
                        borderRadius: BorderRadius.circular(1.r),
                      ),
                      child: SizedBox(width: 24.w, height: 3.h),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Center(
                    child: l10n.changePasswordTitle
                        .s(19.sp)
                        .w(800)
                        .c(colors.iconStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(height: 4.h),
                  l10n.changePasswordSubtitle
                      .s(15.sp)
                      .w(500)
                      .c(colors.textSub)
                      .a(TextAlign.center)
                      .h(20 / 15),
                  SizedBox(height: 24.h),
                  _PasswordField(
                    controller: _oldController,
                    label: l10n.changePasswordOldLabel,
                    hint: l10n.changePasswordOldHint,
                    enabled: !submitting,
                    errorText: oldError,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16.h),
                  _PasswordField(
                    controller: _newController,
                    label: l10n.changePasswordNewLabel,
                    hint: l10n.changePasswordNewHint,
                    enabled: !submitting,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 16.h),
                  _PasswordField(
                    controller: _confirmController,
                    label: l10n.changePasswordConfirmLabel,
                    hint: l10n.changePasswordConfirmHint,
                    enabled: !submitting,
                    errorText: confirmError,
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _CancelButton(
                          onTap: submitting
                              ? null
                              : () => Navigator.of(context).pop(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _SaveButton(
                          enabled: !submitting && _canSubmit,
                          loading: submitting,
                          onSubmit: () => _submit(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Parol maydoni — Figma "Field" komponentiga mos: `background-base` fon,
/// `stroke-sub` ramka (yoki xato holatida `error-sub`), 12 radius. Ostida
/// [errorText] bo'lsa qizil izoh ko'rsatiladi.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.enabled,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = BorderRadius.circular(12.r);
    final hasError = widget.errorText != null;
    final borderColor = hasError ? colors.errorSub : colors.strokeSub;

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.label
            .s(11.sp)
            .w(500)
            .c(colors.textSub)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        SizedBox(height: 4.h),
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscured,
          maxLines: 1,
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.number,
          onChanged: widget.onChanged,
          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            height: 20 / 13,
            color: widget.enabled ? colors.textStrong : colors.textDisabled,
          ),
          cursorColor: colors.accentSub,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.backgroundBase,
            hintText: widget.hint,
            hintStyle: GoogleFonts.manrope(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              height: 20 / 13,
              color: colors.textSoft,
            ),
            contentPadding: EdgeInsets.only(
              left: 16.w,
              right: 8.w,
              top: 12.h,
              bottom: 12.h,
            ),
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscured = !_obscured),
              splashRadius: 20.r,
              icon: (_obscured
                      ? Assets.icons.icEyeOpen
                      : Assets.icons.icEyeClose)
                  .svg(
                width: 20.w,
                height: 20.w,
                colorFilter:
                    ColorFilter.mode(colors.iconSoft, BlendMode.srcIn),
              ),
            ),
            border: border(borderColor, 1),
            enabledBorder: border(borderColor, 1),
            focusedBorder: border(hasError ? colors.errorSub : colors.strokeAccent, 1.5),
            disabledBorder: border(borderColor, 1),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 4.h),
          '*${widget.errorText}'.s(11.sp).w(500).c(colors.errorSub),
        ],
      ],
    );
  }
}

/// "Bekor qilish" — shaffof, X ikonka + matn.
class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        height: 52.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Assets.icons.icClose.svg(
              width: 16.w,
              height: 16.w,
              colorFilter: ColorFilter.mode(colors.textStrong, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
            l10n.changePasswordCancel.s(15.sp).w(800).c(colors.textStrong),
          ],
        ),
      ),
    );
  }
}

/// "Saqlash" — o'chirilgan (`background-elevation-1`/`text-strong`), faol
/// (`accent-strong`/`text-white`), yuklanmoqda (spinner) holatlari.
class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.enabled,
    required this.loading,
    required this.onSubmit,
  });

  final bool enabled;
  final bool loading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final bg = enabled ? colors.accentStrong : colors.backgroundElevation1;
    final fg = enabled ? colors.textWhite : colors.textStrong;

    return InkWell(
      onTap: enabled ? onSubmit : null,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          height: 52.h,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5.w,
                      color: colors.textWhite,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.icTuilconCheck.svg(
                        width: 16.w,
                        height: 16.w,
                        // colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
                      ),
                      SizedBox(width: 8.w),
                      l10n.changePasswordSave.s(15.sp).w(800).c(fg),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Parolni almashtirish dialogini ko'rsatadi. Muvaffaqiyat/xato holati dialog
/// ichida (bloc listener'ida) boshqariladi — chaqiruvchidan qo'shimcha ish
/// talab qilinmaydi.
Future<void> showChangePasswordDialog(BuildContext context) {
  final colors = AppColors.of(context);
  return showDialog<void>(
    context: context,
    barrierColor: colors.black.withValues(alpha: 0.6),
    builder: (_) => BlocProvider<ChangePasswordBloc>(
      create: (_) => getIt<ChangePasswordBloc>(),
      child: const ChangePasswordDialog(),
    ),
  );
}
