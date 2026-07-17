import '../../../../core/usecases/usecase.dart';
import '../entities/ledger_entry.dart';
import '../entities/ledger_filter.dart';
import '../repository/ledger_repository.dart';

/// [GetLedgerUseCase] parametri: sahifa raqami + filtr.
typedef GetLedgerParams = ({int page, LedgerFilter filter});

/// Moliya tarixi sahifasini olish (`GET /ledger/`).
class GetLedgerUseCase implements UseCase<LedgerPage, GetLedgerParams> {
  const GetLedgerUseCase(this._repository);

  final LedgerRepository _repository;

  @override
  Future<LedgerPage> call(GetLedgerParams params) =>
      _repository.getLedger(page: params.page, filter: params.filter);
}
