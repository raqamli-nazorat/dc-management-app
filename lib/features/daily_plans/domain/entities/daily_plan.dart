import 'package:equatable/equatable.dart';

enum DailyPlanColor {
  red,
  green,
  blue,
  yellow;

  static DailyPlanColor fromApi(String? value) =>
      DailyPlanColor.values.firstWhere(
        (color) => color.name == value,
        orElse: () => DailyPlanColor.blue,
      );
}

class DailyPlanItem extends Equatable {
  const DailyPlanItem({
    required this.id,
    required this.title,
    required this.isDone,
  });

  final int id;
  final String title;
  final bool isDone;

  @override
  List<Object> get props => [id, title, isDone];
}

class DailyPlan extends Equatable {
  const DailyPlan({
    required this.id,
    required this.title,
    required this.color,
    required this.isDone,
    required this.items,
    required this.createdAt,
  });

  final int id;
  final String title;
  final DailyPlanColor color;
  final bool isDone;
  final List<DailyPlanItem> items;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [id, title, color, isDone, items, createdAt];
}
