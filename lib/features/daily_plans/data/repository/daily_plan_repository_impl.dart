import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../../domain/repository/daily_plan_repository.dart';
import '../data_sources/daily_plan_remote_data_source.dart';

class DailyPlanRepositoryImpl implements DailyPlanRepository {
  const DailyPlanRepositoryImpl(this._remote);
  final DailyPlanRemoteDataSource _remote;

  @override
  Future<List<DailyPlan>> getPlans() => _guard(_remote.getPlans);
  @override
  Future<DailyPlan> createPlan(DailyPlanInput input) =>
      _guard(() => _remote.createPlan(input));
  @override
  Future<DailyPlan> updatePlan(int id, DailyPlanInput input) =>
      _guard(() => _remote.updatePlan(id, input));
  @override
  Future<void> deletePlan(int id) => _guard(() => _remote.deletePlan(id));
  @override
  Future<DailyPlanItem> createItem(int planId, String title) =>
      _guard(() => _remote.createItem(planId, title));
  @override
  Future<DailyPlanItem> updateItem(
    DailyPlanItem item, {
    String? title,
    bool? isDone,
  }) => _guard(() => _remote.updateItem(item, title: title, isDone: isDone));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (error) {
      throw UnauthorizedFailure(error.message);
    } on ThrottleException catch (error) {
      throw ThrottleFailure(error.message);
    } on NetworkException catch (error) {
      throw NetworkFailure(error.message);
    } on ServerException catch (error) {
      throw ServerFailure(error.message);
    }
  }
}
