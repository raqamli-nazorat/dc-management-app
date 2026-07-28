import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/no_params.dart';
import '../../domain/entities/daily_plan.dart';
import '../../domain/entities/daily_plan_input.dart';
import '../../domain/usecases/daily_plan_usecases.dart';

part 'daily_plans_event.dart';
part 'daily_plans_state.dart';

class DailyPlansBloc extends Bloc<DailyPlansEvent, DailyPlansState> {
  DailyPlansBloc({
    required GetDailyPlansUseCase getPlans,
    required CreateDailyPlanUseCase createPlan,
    required UpdateDailyPlanUseCase updatePlan,
    required DeleteDailyPlanUseCase deletePlan,
    required CreateDailyPlanItemUseCase createItem,
    required UpdateDailyPlanItemUseCase updateItem,
  }) : _getPlans = getPlans,
       _createPlan = createPlan,
       _updatePlan = updatePlan,
       _deletePlan = deletePlan,
       _createItem = createItem,
       _updateItem = updateItem,
       super(const DailyPlansState()) {
    on<DailyPlansRequested>(_onRequested);
    on<DailyPlanSaved>(_onSaved);
    on<DailyPlanFormSaved>(_onFormSaved);
    on<DailyPlanDeleted>(_onDeleted);
    on<DailyPlanItemSaved>(_onItemSaved);
  }

  final GetDailyPlansUseCase _getPlans;
  final CreateDailyPlanUseCase _createPlan;
  final UpdateDailyPlanUseCase _updatePlan;
  final DeleteDailyPlanUseCase _deletePlan;
  final CreateDailyPlanItemUseCase _createItem;
  final UpdateDailyPlanItemUseCase _updateItem;

  Future<void> _onRequested(
    DailyPlansRequested event,
    Emitter<DailyPlansState> emit,
  ) async {
    emit(state.copyWith(status: DailyPlansStatus.loading));
    try {
      emit(
        state.copyWith(
          status: DailyPlansStatus.success,
          plans: await _getPlans(NoParams()),
        ),
      );
    } on Failure catch (failure) {
      emit(state.copyWith(status: DailyPlansStatus.failure, failure: failure));
    }
  }

  Future<void> _onSaved(
    DailyPlanSaved event,
    Emitter<DailyPlansState> emit,
  ) async {
    try {
      if (event.id == null) {
        final plan = await _createPlan(event.input);
        emit(
          state.copyWith(
            plans: [plan, ...state.plans],
            message: DailyPlansMessage.planSaved,
          ),
        );
      } else {
        final plan = await _updatePlan((id: event.id!, input: event.input));
        emit(
          state.copyWith(
            plans: _replacePlan(plan),
            message: DailyPlansMessage.planSaved,
          ),
        );
      }
    } on Failure catch (failure) {
      emit(
        state.copyWith(failure: failure, message: DailyPlansMessage.failure),
      );
    }
  }

  Future<void> _onDeleted(
    DailyPlanDeleted event,
    Emitter<DailyPlansState> emit,
  ) async {
    final oldPlans = state.plans;
    emit(
      state.copyWith(
        plans: oldPlans.where((plan) => plan.id != event.id).toList(),
      ),
    );
    try {
      await _deletePlan(event.id);
      emit(state.copyWith(message: DailyPlansMessage.planDeleted));
    } on Failure catch (failure) {
      emit(
        state.copyWith(
          plans: oldPlans,
          failure: failure,
          message: DailyPlansMessage.failure,
        ),
      );
    }
  }

  Future<void> _onFormSaved(
    DailyPlanFormSaved event,
    Emitter<DailyPlansState> emit,
  ) async {
    emit(state.copyWith(clearMessage: true));
    DailyPlan? createdPlan;
    try {
      final plan = event.id == null
          ? await _createPlan(event.input)
          : await _updatePlan((id: event.id!, input: event.input));
      createdPlan = event.id == null ? plan : null;
      final items = await Future.wait(
        event.items.map((draft) {
          final item = draft.item;
          if (item == null) {
            return _createItem((planId: plan.id, title: draft.title));
          }
          return item.title == draft.title
              ? Future.value(item)
              : _updateItem((item: item, title: draft.title, isDone: null));
        }),
      );
      final savedPlan = DailyPlan(
        id: plan.id,
        title: plan.title,
        color: plan.color,
        isDone: plan.isDone,
        items: items,
        createdAt: plan.createdAt,
      );
      emit(
        state.copyWith(
          plans: event.id == null
              ? [savedPlan, ...state.plans]
              : _replacePlan(savedPlan),
          message: DailyPlansMessage.planSaved,
        ),
      );
    } on Failure catch (failure) {
      if (createdPlan != null) {
        try {
          await _deletePlan(createdPlan.id);
        } on Failure {
          // The original failure remains more useful to the form caller.
        }
      }
      emit(
        state.copyWith(failure: failure, message: DailyPlansMessage.failure),
      );
    }
  }

  Future<void> _onItemSaved(
    DailyPlanItemSaved event,
    Emitter<DailyPlansState> emit,
  ) async {
    try {
      final item = event.item == null
          ? await _createItem((planId: event.planId, title: event.title!))
          : await _updateItem((
              item: event.item!,
              title: event.title,
              isDone: event.isDone,
            ));
      final plans = state.plans.map((plan) {
        if (plan.id != event.planId) return plan;
        final items = event.item == null
            ? [...plan.items, item]
            : plan.items.map((old) => old.id == item.id ? item : old).toList();
        return DailyPlan(
          id: plan.id,
          title: plan.title,
          color: plan.color,
          isDone: plan.isDone,
          items: items,
          createdAt: plan.createdAt,
        );
      }).toList();
      emit(state.copyWith(plans: plans));
    } on Failure catch (failure) {
      emit(
        state.copyWith(failure: failure, message: DailyPlansMessage.failure),
      );
    }
  }

  List<DailyPlan> _replacePlan(DailyPlan plan) =>
      state.plans.map((old) => old.id == plan.id ? plan : old).toList();
}
