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
import '../../../reports/domain/entities/expense_report.dart';
import '../../domain/entities/expense_request.dart';
import '../bloc/expense_request_detail_bloc.dart';
import '../widgets/expense_request_dialogs.dart';

/// "So'rov ma'lumotlari" — xarajat so'rovi detail sahifasi
/// (`Routes.expenseRequestDetail`, `GET /expense-request/{id}/`). Figma:
/// node 333-76321 (Boshqa) / 333-76359 (Kompaniya). Maydonlar xarajat turiga
/// qarab o'zgaradi: `withdrawal` — Loyiha ham Toifa ham yo'q; `company` —
/// Loyiha bor, Toifa yo'q; `other` — Toifa bor, Loyiha yo'q. `pending`
/// holatda "Rad etish" (`POST .../cancel/`) va "To'lov qildim"
/// (`POST .../pay/`) tugmalari chiqadi.
class QueryDataPage extends StatelessWidget {
  const QueryDataPage({required this.requestId, super.key});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExpenseRequestDetailBloc>(
      create: (_) =>
          getIt<ExpenseRequestDetailBloc>()
            ..add(ExpenseRequestDetailRequested(requestId)),
      child: _QueryDataView(requestId: requestId),
    );
  }
}

class _QueryDataView extends StatelessWidget {
  const _QueryDataView({required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return BlocListener<ExpenseRequestDetailBloc, ExpenseRequestDetailState>(
      listenWhen: (p, c) =>
          p.actionDone != c.actionDone || p.actionFailure != c.actionFailure,
      listener: (context, state) {
        if (state.actionDone) {
          final paid = state.request?.status == ExpenseStatus.paid;
          // To'lov — yashil success toast; rad etish — orange alert toast.
          if (paid) {
            AppToast.showSuccess(
              context,
              title: l10n.expenseRequestPaySuccess,
              message: l10n.expenseRequestPaySuccessMessage,
            );
          } else {
            AppToast.showError(
              context,
              title: l10n.expenseRequestCancelSuccess,
              message: l10n.expenseRequestCancelSuccessMessage,
            );
          }
          // Ro'yxatga qaytadi va avto-refresh bo'ladi (result: true).
          context.pop(true);
        } else if (state.actionFailure != null) {
          // Backend xabari (masalan huquq yo'qligi yoki qisqa sabab).
          final failure = state.actionFailure!;
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
              AppFilterHeader(title: l10n.expenseRequestDetailTitle),
              Expanded(
                child:
                    BlocBuilder<
                      ExpenseRequestDetailBloc,
                      ExpenseRequestDetailState
                    >(
                      builder: (context, state) {
                        switch (state.status) {
                          case ExpenseRequestDetailStatus.loading:
                          case ExpenseRequestDetailStatus.initial:
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          case ExpenseRequestDetailStatus.failure:
                            return _ErrorState(
                              failure: state.failure,
                              onRetry: () =>
                                  context.read<ExpenseRequestDetailBloc>().add(
                                    ExpenseRequestDetailRequested(requestId),
                                  ),
                            );
                          case ExpenseRequestDetailStatus.success:
                            return _QueryDataBody(
                              request: state.request!,
                              acting: state.acting,
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

class _QueryDataBody extends StatelessWidget {
  const _QueryDataBody({required this.request, required this.acting});

  final ExpenseRequest request;
  final bool acting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final type = request.type;

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
                    initial: request.userName,
                    avatarUrl: request.avatar,
                    size: 84,
                  ),
                ),
                _Field(label: l10n.userDetailFullName, value: request.userName),
                // Kompaniya xarajati — Loyiha alohida, turi to'liq kenglikda.
                if (type == ExpenseType.company)
                  _Field(
                    label: l10n.expenseReportProject,
                    value: request.projectName,
                  ),
                // Boshqa — turi va Toifa yonma-yon; qolganlarida turi yakka.
                if (type == ExpenseType.other)
                  Row(
                    spacing: 12.w,
                    children: [
                      Expanded(
                        child: _Field(
                          label: l10n.expenseReportType,
                          value: _typeLabel(type, l10n),
                        ),
                      ),
                      Expanded(
                        child: _Field(
                          label: l10n.expenseRequestFilterCategory,
                          value: request.categoryName,
                        ),
                      ),
                    ],
                  )
                else
                  _Field(
                    label: l10n.expenseReportType,
                    value: _typeLabel(type, l10n),
                  ),
                // Kompaniya dizaynida Sababi Summadan oldin, qolganlarida keyin.
                if (type == ExpenseType.company) ...[
                  _MultilineField(
                    label: l10n.expenseRequestReasonField,
                    value: request.reason,
                  ),
                  _Field(
                    label: l10n.expenseRequestAmountField,
                    value: Formatters.formatAmountComma(request.amount),
                  ),
                ] else ...[
                  _Field(
                    label: l10n.expenseRequestAmountField,
                    value: Formatters.formatAmountComma(request.amount),
                  ),
                  _MultilineField(
                    label: l10n.expenseRequestReasonField,
                    value: request.reason,
                  ),
                ],
                Row(
                  spacing: 12.w,
                  children: [
                    Expanded(
                      child: _Field(
                        label: l10n.expenseReportCreatedAt,
                        value: _fmt(request.createdAt),
                      ),
                    ),
                    Expanded(
                      child: _Field(
                        label: l10n.expenseReportPaidAt,
                        value: _fmt(request.paidAt),
                      ),
                    ),
                  ],
                ),
                _Field(
                  label: l10n.expenseReportConfirmedAt,
                  value: _fmt(request.confirmedAt),
                ),
              ],
            ),
          ),
        ),
        if (request.status == ExpenseStatus.pending)
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: Row(
              spacing: 12.w,
              children: [
                Expanded(
                  child: _ActionButton(
                    label: l10n.meetingExcuseReject,
                    color: colors.errorStrong,
                    icon: Assets.icons.icClose,
                    loading: acting,
                    onTap: () => _onCancelTap(context),
                  ),
                ),
                Expanded(
                  child: _ActionButton(
                    label: l10n.expenseRequestPayButton,
                    color: colors.accentStrong,
                    icon: Assets.icons.icCheckmarkCircle,
                    loading: acting,
                    onTap: () => _onPayTap(context),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// "To'lov qildim" — avval tasdiq dialogi, "ha" bo'lsa so'rov ketadi.
  Future<void> _onPayTap(BuildContext context) async {
    final bloc = context.read<ExpenseRequestDetailBloc>();
    final confirmed = await showExpenseRequestPayDialog(context);
    if (confirmed == true) bloc.add(const ExpenseRequestPayRequested());
  }

  /// "Rad etish" — sabab dialogi, sabab kiritilsa so'rov ketadi.
  Future<void> _onCancelTap(BuildContext context) async {
    final bloc = context.read<ExpenseRequestDetailBloc>();
    final reason = await showExpenseRequestCancelDialog(context);
    if (reason != null && reason.isNotEmpty) {
      bloc.add(ExpenseRequestCancelRequested(reason));
    }
  }

  static String _fmt(DateTime? date) =>
      date == null ? '' : DateFormat('dd.MM.yyyy HH:mm').format(date);
}

String _typeLabel(ExpenseType t, AppLocalizations l10n) => switch (t) {
  ExpenseType.withdrawal => l10n.expenseReportTypeWithdrawal,
  ExpenseType.company => l10n.expenseReportTypeCompany,
  ExpenseType.other => l10n.expenseReportTypeOther,
  ExpenseType.unknown => '',
};

/// Yorliq + faqat o'qish uchun boxed qiymat.
class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

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
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Yorliq + ko'p qatorli faqat o'qish uchun boxed qiymat (Sababi).
class _MultilineField extends StatelessWidget {
  const _MultilineField({required this.label, required this.value});

  final String label;
  final String value;

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
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 64.h),
                child: value
                    .s(13.sp)
                    .w(500)
                    .h(20 / 13)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 6, overflow: TextOverflow.ellipsis),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rangli pastki tugma (ikonka + yorliq); amal ketayotganda bloklanadi.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final Color color;
  final SvgGenImage icon;
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color,
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
                      icon.svg(
                        width: 20.w,
                        height: 20.w,
                        colorFilter: ColorFilter.mode(
                          colors.textWhite,
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: label
                            .s(15.sp)
                            .w(700)
                            .c(colors.textWhite)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
