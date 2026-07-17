import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ledger_entry.dart';

/// Tranzaksiya turi → lokalizatsiya (bloclar kontekstsiz, matn widget qatlamida).
String transactionTypeLabel(TransactionType type, AppLocalizations l10n) =>
    switch (type) {
      TransactionType.debit => l10n.ledgerTypeExpense,
      TransactionType.credit => l10n.ledgerTypeIncome,
      TransactionType.unknown => '',
    };
