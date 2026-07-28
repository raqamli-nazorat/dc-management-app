import 'package:dc_management_app/features/daily_plans/domain/entities/daily_plan.dart';
import 'package:dc_management_app/features/daily_plans/domain/entities/daily_plan_input.dart';
import 'package:dc_management_app/features/daily_plans/domain/repository/daily_plan_repository.dart';
import 'package:dc_management_app/features/daily_plans/domain/usecases/daily_plan_usecases.dart';
import 'package:dc_management_app/features/daily_plans/presentation/bloc/daily_plans_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('form save creates its non-empty subtasks with the plan', () async {
    final repository = _DailyPlanRepositoryFake();
    final bloc = DailyPlansBloc(
      getPlans: GetDailyPlansUseCase(repository),
      createPlan: CreateDailyPlanUseCase(repository),
      updatePlan: UpdateDailyPlanUseCase(repository),
      deletePlan: DeleteDailyPlanUseCase(repository),
      createItem: CreateDailyPlanItemUseCase(repository),
      updateItem: UpdateDailyPlanItemUseCase(repository),
    );
    addTearDown(bloc.close);

    bloc.add(
      const DailyPlanFormSaved(
        input: DailyPlanInput(
          title: 'Dashboard chizish',
          color: DailyPlanColor.yellow,
        ),
        items: [
          (item: null, title: 'Research'),
          (item: null, title: 'Frame chizish'),
        ],
      ),
    );

    final state = await bloc.stream.firstWhere(
      (state) => state.message == DailyPlansMessage.planSaved,
    );

    expect(state.plans.single.title, 'Dashboard chizish');
    expect(state.plans.single.items.map((item) => item.title), [
      'Research',
      'Frame chizish',
    ]);
    expect(repository.createdItemPlanIds, [1, 1]);
  });
}

class _DailyPlanRepositoryFake implements DailyPlanRepository {
  final List<int> createdItemPlanIds = [];
  var _nextItemId = 1;

  @override
  Future<DailyPlan> createPlan(DailyPlanInput input) async => DailyPlan(
    id: 1,
    title: input.title,
    color: input.color,
    isDone: input.isDone ?? false,
    items: const [],
    createdAt: DateTime(2026),
  );

  @override
  Future<DailyPlanItem> createItem(int planId, String title) async {
    createdItemPlanIds.add(planId);
    return DailyPlanItem(id: _nextItemId++, title: title, isDone: false);
  }

  @override
  Future<void> deletePlan(int id) async {}

  @override
  Future<List<DailyPlan>> getPlans() async => const [];

  @override
  Future<DailyPlanItem> updateItem(
    DailyPlanItem item, {
    String? title,
    bool? isDone,
  }) async => DailyPlanItem(
    id: item.id,
    title: title ?? item.title,
    isDone: isDone ?? item.isDone,
  );

  @override
  Future<DailyPlan> updatePlan(int id, DailyPlanInput input) async => DailyPlan(
    id: id,
    title: input.title,
    color: input.color,
    isDone: input.isDone ?? false,
    items: const [],
    createdAt: DateTime(2026),
  );
}
