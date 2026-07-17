import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/app_filter_components.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ledger_entry.dart';
import '../bloc/ledger_detail_bloc.dart';
import '../widgets/transaction_type_label.dart';

/// Moliya tarixi detail sahifasi (`Routes.ledgerDetail`, `GET /ledger/{id}/`) —
/// Figma "Tarix ma'lumotlari": faqat o'qish uchun boxed maydonlar.
class LedgerDetailPage extends StatelessWidget {
  const LedgerDetailPage({required this.entryId, super.key});

  final int entryId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LedgerDetailBloc>(
      create: (_) =>
          getIt<LedgerDetailBloc>()..add(LedgerDetailRequested(entryId)),
      child: _LedgerDetailView(entryId: entryId),
    );
  }
}

class _LedgerDetailView extends StatelessWidget {
  const _LedgerDetailView({required this.entryId});

  final int entryId;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: Column(
          children: [
            AppFilterHeader(title: l10n.ledgerDetailTitle),
            Expanded(
              child: BlocBuilder<LedgerDetailBloc, LedgerDetailState>(
                builder: (context, state) {
                  switch (state.status) {
                    case LedgerDetailStatus.loading:
                    case LedgerDetailStatus.initial:
                      return const Center(child: CircularProgressIndicator());
                    case LedgerDetailStatus.failure:
                      return _ErrorState(
                        failure: state.failure,
                        onRetry: () => context.read<LedgerDetailBloc>().add(
                          LedgerDetailRequested(entryId),
                        ),
                      );
                    case LedgerDetailStatus.success:
                      return _LedgerDetailBody(entry: state.entry!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerDetailBody extends StatelessWidget {
  const _LedgerDetailBody({required this.entry});

  final LedgerEntry entry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12.h,
        children: [
          Center(
            child: TuiAvatar(
              initial: entry.userName,
              avatarUrl: entry.avatar,
              size: 84,
            ),
          ),
          _ReadonlyField(label: l10n.userDetailFullName, value: entry.userName),
          _ReadonlyField(
            label: l10n.ledgerDetailExpenseType,
            value: transactionTypeLabel(entry.transactionType, l10n),
          ),
          Row(
            spacing: 12.w,
            children: [
              Expanded(
                child: _ReadonlyField(
                  label: l10n.userDetailSalary,
                  value: Formatters.formatAmountComma(entry.fixedSalary),
                ),
              ),
              Expanded(
                child: _ReadonlyField(
                  label: l10n.ledgerDetailAmount,
                  value: Formatters.formatAmountComma(entry.amount),
                ),
              ),
            ],
          ),
          _ReadonlyField(
            label: l10n.ledgerDetailConfirmedAt,
            value: entry.createdAt == null
                ? ''
                : DateFormat('dd.MM.yyyy').format(entry.createdAt!),
          ),
        ],
      ),
    );
  }
}

/// Yorliq + faqat o'qish uchun boxed qiymat (filtr maydonlari ko'rinishi).
class _ReadonlyField extends StatelessWidget {
  const _ReadonlyField({required this.label, required this.value});

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
                    .w(500)
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
