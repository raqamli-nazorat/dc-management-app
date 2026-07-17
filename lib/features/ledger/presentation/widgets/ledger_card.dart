import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/util/formatters.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ledger_entry.dart';
import 'transaction_type_label.dart';

/// Bitta moliya tarixi kartasi — "Tarix" ro'yxati (Figma card). Bosilганda
/// detail sahifasiga o'tadi.
class LedgerCard extends StatelessWidget {
  const LedgerCard({required this.entry, this.onTap, super.key});

  final LedgerEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.backgroundElevation1,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.strokeSoft, width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TuiAvatar(
                initial: entry.userName,
                avatarUrl: entry.avatar,
                size: 40,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.h,
                  children: [
                    _Line(label: l10n.userFullNameLabel, value: entry.userName),
                    _Line(
                      label: l10n.ledgerTypeLabel,
                      value: transactionTypeLabel(entry.transactionType, l10n),
                    ),
                    _Line(
                      label: l10n.ledgerAmountLabel,
                      value: Formatters.formatAmountComma(entry.amount),
                    ),
                    _Line(
                      label: l10n.ledgerDateLabel,
                      value: entry.createdAt == null
                          ? ''
                          : DateFormat('dd.MM.yyyy').format(entry.createdAt!),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Yorliq: **Qiymat**" qatori — yorliq kulrang, qiymat qalin.
class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Text.rich(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: colors.textSub,
              fontFamily: 'Manrope',
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: colors.textStrong,
              fontFamily: 'Manrope',
            ),
          ),
        ],
      ),
    );
  }
}
