import 'daily_plan.dart';

class DailyPlanInput {
  const DailyPlanInput({required this.title, required this.color, this.isDone});

  final String title;
  final DailyPlanColor color;
  final bool? isDone;
}
