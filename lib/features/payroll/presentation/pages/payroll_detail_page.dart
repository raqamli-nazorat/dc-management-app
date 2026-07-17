import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/payroll.dart';
import '../bloc/payroll_detail_bloc.dart';
import '../widgets/payroll_confirm_dialog.dart';

/// Ish haqi detail sahifasi (`Routes.payrollDetail`, `GET /payroll/{id}/`) —
/// Figma "Ish haqi ma'lumotlari": faqat o'qish uchun boxed maydonlar +
/// "Tasdiqlash" tugmasi (`POST /payroll/confirm/`).
class PayrollDetailPage extends StatelessWidget {
  const PayrollDetailPage({required this.payrollId, super.key});

  final int payrollId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PayrollDetailBloc>(
      create: (_) =>
          getIt<PayrollDetailBloc>()..add(PayrollDetailRequested(payrollId)),
      child: _PayrollDetailView(payrollId: payrollId),
    );
  }
}

class _PayrollDetailView extends StatelessWidget {
  const _PayrollDetailView({required this.payrollId});

  final int payrollId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<PayrollDetailBloc, PayrollDetailState>(
      listenWhen: (p, c) =>
          p.confirmed != c.confirmed || p.confirmFailure != c.confirmFailure,
      listener: (context, state) {
        if (state.confirmed) {
          AppToast.showSuccess(context, title: l10n.payrollConfirmSuccess);
          // Tasdiqlandi — ro'yxatga qaytadi va avto-refresh bo'ladi (result: true).
          context.pop(true);
        } else if (state.confirmFailure != null) {
          // Backend xabari (masalan "Sizda oyliklarni tasdiqlash huquqi yo'q").
          final failure = state.confirmFailure!;
          AppToast.showError(
            context,
            title: failure is NetworkFailure
                ? l10n.networkError
                : failure.message,
          );
        }
      },
      child: Scaffold(
        backgroundColor: colors.backgroundBase,
        body: SafeArea(
          child: Column(
            children: [
              AppFilterHeader(title: l10n.payrollDetailTitle),
              Expanded(
                child: BlocBuilder<PayrollDetailBloc, PayrollDetailState>(
                  builder: (context, state) {
                    switch (state.status) {
                      case PayrollDetailStatus.loading:
                      case PayrollDetailStatus.initial:
                        return const Center(child: CircularProgressIndicator());
                      case PayrollDetailStatus.failure:
                        return _ErrorState(
                          failure: state.failure,
                          onRetry: () => context.read<PayrollDetailBloc>().add(
                            PayrollDetailRequested(payrollId),
                          ),
                        );
                      case PayrollDetailStatus.success:
                        return _PayrollDetailBody(
                          payroll: state.payroll!,
                          confirming: state.confirming,
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayrollDetailBody extends StatelessWidget {
  const _PayrollDetailBody({required this.payroll, required this.confirming});

  final Payroll payroll;
  final bool confirming;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12.h,
              children: [
                Center(
                  child: TuiAvatar(
                    initial: payroll.userName,
                    avatarUrl: payroll.avatar,
                    size: 84,
                  ),
                ),
                _Field(label: l10n.userDetailFullName, value: payroll.userName),
                Row(
                  spacing: 12.w,
                  children: [
                    Expanded(
                      child: _Field(
                        label: l10n.payrollMonthField,
                        value: payroll.monthDisplay,
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: l10n.payrollSalaryField,
                        value: Formatters.formatAmountComma(
                          payroll.fixedSalary,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 12.w,
                  children: [
                    Expanded(
                      child: _Field(
                        label: l10n.payrollKpiField,
                        value: Formatters.formatAmountComma(payroll.kpiBonus),
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: l10n.payrollPenaltyField,
                        value: _penaltyText(payroll.penaltyAmount),
                        valueColor: colors.errorStrong,
                      ),
                    ),
                  ],
                ),
                _Field(
                  label: l10n.payrollTotalField,
                  value: Formatters.formatAmountComma(payroll.totalAmount),
                ),
                _Field(
                  label: l10n.userDetailCreatedAt,
                  value: payroll.createdAt == null
                      ? ''
                      : DateFormat('dd.MM.yyyy').format(payroll.createdAt!),
                ),
              ],
            ),
          ),
        ),
        if (!payroll.isConfirmed)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: _ConfirmButton(
              loading: confirming,
              onTap: () => _onConfirmTap(context),
            ),
          ),
      ],
    );
  }

  /// Tasdiqlash tugmasi — avval tasdiq dialogi, "ha" bo'lsa so'rov ketadi.
  Future<void> _onConfirmTap(BuildContext context) async {
    final bloc = context.read<PayrollDetailBloc>();
    final confirmed = await showPayrollConfirmDialog(context);
    if (confirmed == true) bloc.add(const PayrollConfirmRequested());
  }

  /// Jarima manfiy/qizil ko'rsatiladi: `75000.00` → `-75 000,00` (agar != 0).
  /// Raw kasrlari saqlanadi; API musbat qiymat yuboradi, UI minus qo'shadi.
  static String _penaltyText(String raw) {
    if (raw.isEmpty) return '';
    final n = num.tryParse(raw);
    final body = Formatters.formatAmountComma(
      raw.startsWith('-') ? raw.substring(1) : raw,
    );
    if (n == null || n == 0) return body;
    return '-$body';
  }
}

/// Yorliq + faqat o'qish uchun boxed qiymat.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: appFilterFieldDecoration(colors),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SizedBox(
              height: 44.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: value
                    .s(13.sp)
                    .w(700)
                    .h(20 / 13)
                    .c(valueColor ?? colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Yashil "✓ Tasdiqlash" tugmasi (dizayn success rangi — accentStrong emas).
class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({required this.loading, required this.onTap});

  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.successStrong,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: SizedBox(
          height: 52.h,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20.r,
                    height: 20.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.r,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colors.textWhite,
                      ),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.icCheckmarkCircle.svg(
                        width: 20.w,
                        height: 20.w,
                        colorFilter: ColorFilter.mode(
                          colors.textWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      l10n.payrollConfirmButton
                          .s(15.sp)
                          .w(700)
                          .c(colors.textWhite),
                    ],
                  ),
          ),
        ),
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
