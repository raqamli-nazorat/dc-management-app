import '../entities/daily_plan.dart';
import '../entities/daily_plan_input.dart';

abstract interface class DailyPlanRepository {
  Future<List<DailyPlan>> getPlans();
  Future<DailyPlan> createPlan(DailyPlanInput input);
  Future<DailyPlan> updatePlan(int id, DailyPlanInput input);
  Future<void> deletePlan(int id);
  Future<DailyPlanItem> createItem(int planId, String title);
  Future<DailyPlanItem> updateItem(
    DailyPlanItem item, {
    String? title,
    bool? isDone,
  });
}
