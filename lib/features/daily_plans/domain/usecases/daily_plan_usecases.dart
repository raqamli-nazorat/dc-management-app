import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/daily_plan.dart';
import '../entities/daily_plan_input.dart';
import '../repository/daily_plan_repository.dart';

class GetDailyPlansUseCase implements UseCase<List<DailyPlan>, NoParams> {
  const GetDailyPlansUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<List<DailyPlan>> call(NoParams params) => _repository.getPlans();
}

class CreateDailyPlanUseCase implements UseCase<DailyPlan, DailyPlanInput> {
  const CreateDailyPlanUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<DailyPlan> call(DailyPlanInput params) =>
      _repository.createPlan(params);
}

typedef UpdateDailyPlanParams = ({int id, DailyPlanInput input});

class UpdateDailyPlanUseCase
    implements UseCase<DailyPlan, UpdateDailyPlanParams> {
  const UpdateDailyPlanUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<DailyPlan> call(UpdateDailyPlanParams params) =>
      _repository.updatePlan(params.id, params.input);
}

class DeleteDailyPlanUseCase implements UseCase<void, int> {
  const DeleteDailyPlanUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<void> call(int params) => _repository.deletePlan(params);
}

typedef CreateDailyPlanItemParams = ({int planId, String title});

class CreateDailyPlanItemUseCase
    implements UseCase<DailyPlanItem, CreateDailyPlanItemParams> {
  const CreateDailyPlanItemUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<DailyPlanItem> call(CreateDailyPlanItemParams params) =>
      _repository.createItem(params.planId, params.title);
}

typedef UpdateDailyPlanItemParams = ({
  DailyPlanItem item,
  String? title,
  bool? isDone,
});

class UpdateDailyPlanItemUseCase
    implements UseCase<DailyPlanItem, UpdateDailyPlanItemParams> {
  const UpdateDailyPlanItemUseCase(this._repository);
  final DailyPlanRepository _repository;
  @override
  Future<DailyPlanItem> call(UpdateDailyPlanItemParams params) => _repository
      .updateItem(params.item, title: params.title, isDone: params.isDone);
}
