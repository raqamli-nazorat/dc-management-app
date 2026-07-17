import '../../../../core/usecases/usecase.dart';
import '../entities/ledger_entry.dart';
import '../repository/ledger_repository.dart';

/// Bitta tarix yozuvini olish (`GET /ledger/{id}/`).
class GetLedgerDetailUseCase implements UseCase<LedgerEntry, int> {
  const GetLedgerDetailUseCase(this._repository);

  final LedgerRepository _repository;

  @override
  Future<LedgerEntry> call(int id) => _repository.getLedgerEntry(id);
}
