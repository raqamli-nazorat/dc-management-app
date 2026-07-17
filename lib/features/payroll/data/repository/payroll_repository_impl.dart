import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payroll.dart';
import '../../domain/entities/payroll_filter.dart';
import '../../domain/repository/payroll_repository.dart';
import '../data_sources/payroll_remote_data_source.dart';

/// [PayrollRepository] implementatsiyasi — data source `Exception`larini domen
/// `Failure`lariga aylantiradi.
class PayrollRepositoryImpl implements PayrollRepository {
  const PayrollRepositoryImpl(this._remote);

  final PayrollRemoteDataSource _remote;

  @override
  Future<PayrollPage> getPayrolls({
    int page = 1,
    PayrollFilter filter = PayrollFilter.empty,
  }) => _guard(() => _remote.getPayrolls(page: page, filter: filter));

  @override
  Future<Payroll> getPayroll(int id) => _guard(() => _remote.getPayroll(id));

  @override
  Future<void> confirmPayrolls(List<int> ids) =>
      _guard(() => _remote.confirmPayrolls(ids));

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
