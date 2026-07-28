part of 'daily_plans_bloc.dart';

sealed class DailyPlansEvent extends Equatable {
  const DailyPlansEvent();
  @override
  List<Object?> get props => [];
}

class DailyPlansRequested extends DailyPlansEvent {
  const DailyPlansRequested();
}

class DailyPlanSaved extends DailyPlansEvent {
  const DailyPlanSaved(this.input, {this.id});
  final int? id;
  final DailyPlanInput input;
  @override
  List<Object?> get props => [id, input];
}

class DailyPlanFormSaved extends DailyPlansEvent {
  const DailyPlanFormSaved({required this.input, required this.items, this.id});

  final int? id;
  final DailyPlanInput input;
  final List<({DailyPlanItem? item, String title})> items;

  @override
  List<Object?> get props => [id, input, items];
}

class DailyPlanDeleted extends DailyPlansEvent {
  const DailyPlanDeleted(this.id);
  final int id;
  @override
  List<Object> get props => [id];
}

class DailyPlanItemSaved extends DailyPlansEvent {
  const DailyPlanItemSaved({
    required this.planId,
    this.item,
    this.title,
    this.isDone,
  });
  final int planId;
  final DailyPlanItem? item;
  final String? title;
  final bool? isDone;
  @override
  List<Object?> get props => [planId, item, title, isDone];
}
