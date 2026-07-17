import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ledger_entry.dart';
import '../../domain/entities/ledger_filter.dart';
import '../../domain/repository/ledger_repository.dart';
import '../data_sources/ledger_remote_data_source.dart';

/// [LedgerRepository] implementatsiyasi — data source `Exception`larini domen
/// `Failure`lariga aylantiradi.
class LedgerRepositoryImpl implements LedgerRepository {
  const LedgerRepositoryImpl(this._remote);

  final LedgerRemoteDataSource _remote;

  @override
  Future<LedgerPage> getLedger({
    int page = 1,
    LedgerFilter filter = LedgerFilter.empty,
  }) => _guard(() => _remote.getLedger(page: page, filter: filter));

  @override
  Future<LedgerEntry> getLedgerEntry(int id) =>
      _guard(() => _remote.getLedgerEntry(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
