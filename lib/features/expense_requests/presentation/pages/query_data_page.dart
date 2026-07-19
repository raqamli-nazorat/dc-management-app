import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../app/bloc/session_bloc.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/access/role_type.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../reports/domain/entities/expense_report.dart';
import '../../domain/entities/expense_receipt.dart';
import '../../domain/entities/expense_request.dart';
import '../bloc/expense_request_detail_bloc.dart';
import '../widgets/expense_request_dialogs.dart';
import '../widgets/expense_request_receipt_dialog.dart';
import '../widgets/receipt_viewer.dart';

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
          // Yakuniy holatga qarab toast: to'landi — yashil; tasdiqlandi —
          // yashil; rad etildi — orange alert.
          switch (state.action) {
            case ExpenseRequestAction.pay:
              AppToast.showSuccess(
                context,
                title: l10n.expenseRequestPaySuccess,
                message: l10n.expenseRequestPaySuccessMessage,
              );
            case ExpenseRequestAction.confirm:
              AppToast.showSuccess(
                context,
                title: l10n.expenseRequestConfirmSuccess,
                message: l10n.expenseRequestConfirmSuccessMessage,
              );
            case ExpenseRequestAction.cancel:
              AppToast.showError(
                context,
                title: l10n.expenseRequestCancelSuccess,
                message: l10n.expenseRequestCancelSuccessMessage,
              );
            case ExpenseRequestAction.none:
              return;
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
                              receipts: state.receipts,
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
  const _QueryDataBody({
    required this.request,
    required this.receipts,
    required this.acting,
  });

  final ExpenseRequest request;
  final List<ExpenseReceipt> receipts;
  final bool acting;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final type = request.type;
    // "Rad etish" / "To'lov qildim" — faqat hisobchi (moliyachi) uchun.
    final isAccountant =
        context.select<SessionBloc, RoleType>((b) => b.state.roleType) ==
        RoleType.accountant;

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
                // To'lov qayd etilgach yaratuvchi rekvizitlarni tekshiradi.
                if (request.status == ExpenseStatus.paid ||
                    request.status == ExpenseStatus.confirmed) ...[
                  if (request.cardNumber.isNotEmpty)
                    Row(
                      spacing: 12.w,
                      children: [
                        Expanded(
                          child: _Field(
                            label: l10n.expenseReportPaymentMethod,
                            value: _paymentLabel(request.paymentMethod, l10n),
                          ),
                        ),
                        Expanded(
                          child: _CardNumberField(
                            cardNumber: request.cardNumber,
                          ),
                        ),
                      ],
                    )
                  else
                    _Field(
                      label: l10n.expenseReportPaymentMethod,
                      value: _paymentLabel(request.paymentMethod, l10n),
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
                // Rad etilgan — status + sabab; qabul qilingan — cheklar.
                if (request.status == ExpenseStatus.cancelled)
                  _RejectedSection(reason: request.cancelReason)
                else if (receipts.isNotEmpty)
                  _ReceiptsSection(receipts: receipts),
              ],
            ),
          ),
        ),
        if (request.status == ExpenseStatus.pending && isAccountant)
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
          )
        // To'lov qayd etilgach — so'rov yaratuvchisi tasdiqlaydi.
        else if (request.status == ExpenseStatus.paid &&
            request.userId != null &&
            request.userId == _cachedUserId())
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
            child: _ActionButton(
              label: l10n.expenseRequestConfirmButton,
              color: colors.accentStrong,
              icon: Assets.icons.icCheckmarkCircle,
              loading: acting,
              onTap: () => _onConfirmActionTap(context),
            ),
          ),
      ],
    );
  }

  /// "Tasdiqlash" — pay dialogi (Figma image 2) ko'rsatiladi; tasdiqlansa
  /// `POST /expense-request/{id}/confirm/` ketadi.
  Future<void> _onConfirmActionTap(BuildContext context) async {
    final bloc = context.read<ExpenseRequestDetailBloc>();
    final confirmed = await showExpenseRequestPayDialog(context);
    if (confirmed == true) {
      bloc.add(const ExpenseRequestConfirmRequested());
    }
  }

  /// "To'lov qildim" — avval tasdiq dialogi, "ha" bo'lsa chek yuklash dialogi;
  /// undan qaytgan fayllar (yoki bo'sh — "O'tkazib yuborish") bilan to'lov
  /// so'rovi ketadi. Chek dialogi bekor qilinsa (barrier) — to'lov qilinmaydi.
  Future<void> _onPayTap(BuildContext context) async {
    final bloc = context.read<ExpenseRequestDetailBloc>();
    final confirmed = await showExpenseRequestPayDialog(context);
    if (confirmed != true || !context.mounted) return;
    final receiptPaths = await showExpenseRequestReceiptDialog(context);
    if (receiptPaths != null) {
      bloc.add(ExpenseRequestPayRequested(receiptPaths));
    }
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

int? _cachedUserId() {
  final raw = getIt<StorageService>().getString(StorageKeys.cachedUser);
  if (raw == null || raw.isEmpty) return null;
  try {
    final user = jsonDecode(raw);
    return user is Map ? (user['id'] as num?)?.toInt() : null;
  } on Object {
    return null;
  }
}

String _paymentLabel(ExpensePaymentMethod m, AppLocalizations l10n) =>
    switch (m) {
      ExpensePaymentMethod.cash => l10n.expenseReportPaymentCash,
      ExpensePaymentMethod.card => l10n.expenseReportPaymentCard,
      ExpensePaymentMethod.unknown => '',
    };

/// Karta raqami maydoni — bosilganda buferga nusxalanadi (nusxa ikonkasi
/// dizayn assetida yo'q, shu bois butun maydon bosiladigan qilingan).
class _CardNumberField extends StatelessWidget {
  const _CardNumberField({required this.cardNumber});

  final String cardNumber;

  Future<void> _copy(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: cardNumber));
    if (context.mounted) {
      AppToast.showSuccess(context, title: l10n.expenseRequestCardCopied);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(l10n.expenseReportCard),
        InkWell(
          onTap: () => _copy(context),
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
                      child: cardNumber
                          .s(13.sp)
                          .w(700)
                          .h(20 / 13)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    SizedBox(width: 8.w),
                    Assets.icons.icShareNodes.svg(
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
        ),
      ],
    );
  }
}

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

/// Rad etilgan so'rov bo'limi — "Rad etilgan" status + rad etish sababi.
class _RejectedSection extends StatelessWidget {
  const _RejectedSection({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 12.h,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFilterFieldLabel(l10n.taskFilterStatus),
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.errorSub,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colors.errorStrong, width: 1.w),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: SizedBox(
                  height: 44.h,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: l10n.expenseRequestStatusRejected
                        .s(13.sp)
                        .w(700)
                        .h(20 / 13)
                        .c(colors.textStrong),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (reason.isNotEmpty)
          _MultilineField(label: l10n.expenseReportCancelReason, value: reason),
      ],
    );
  }
}

/// Qabul qilingan so'rov cheklari — bosilganda to'liq ekranli ko'rish.
class _ReceiptsSection extends StatelessWidget {
  const _ReceiptsSection({required this.receipts});

  final List<ExpenseReceipt> receipts;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spacing = 12.w;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppFilterFieldLabel(l10n.expenseRequestReceiptsTitle),
        LayoutBuilder(
          builder: (context, constraints) {
            final tileWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final r in receipts)
                  _ReceiptThumb(
                    width: tileWidth,
                    url: r.fileUrl,
                    onTap: () => showReceiptViewer(context, r.fileUrl),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ReceiptThumb extends StatelessWidget {
  const _ReceiptThumb({
    required this.width,
    required this.url,
    required this.onTap,
  });

  final double width;
  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.network(
          url,
          width: width,
          height: 140.h,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => DecoratedBox(
            decoration: BoxDecoration(color: colors.backgroundElevation1Alt),
            child: SizedBox(
              width: width,
              height: 140.h,
              child: Center(
                child: Assets.icons.icDocument.svg(
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconSub,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
