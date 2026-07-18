import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_request.dart';
import '../../domain/entities/expense_request_filter.dart';
import '../../domain/repository/expense_requests_repository.dart';
import '../data_sources/expense_requests_remote_data_source.dart';

/// [ExpenseRequestsRepository] implementatsiyasi — data source
/// `Exception`larini domen `Failure`lariga aylantiradi.
class ExpenseRequestsRepositoryImpl implements ExpenseRequestsRepository {
  const ExpenseRequestsRepositoryImpl(this._remote);

  final ExpenseRequestsRemoteDataSource _remote;

  @override
  Future<ExpenseRequestPage> getExpenseRequests({
    int page = 1,
    ExpenseRequestFilter filter = ExpenseRequestFilter.empty,
  }) => _guard(() => _remote.getExpenseRequests(page: page, filter: filter));

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
