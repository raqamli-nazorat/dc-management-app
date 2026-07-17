import '../entities/ledger_entry.dart';
import '../entities/ledger_filter.dart';

/// Moliya tarixi domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class LedgerRepository {
  /// Bitta sahifa (`GET /ledger/?page=` + filtr paramlari).
  Future<LedgerPage> getLedger({int page, LedgerFilter filter});

  /// Bitta yozuv (`GET /ledger/{id}/`).
  Future<LedgerEntry> getLedgerEntry(int id);
}
