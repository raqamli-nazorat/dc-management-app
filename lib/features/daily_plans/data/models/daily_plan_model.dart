import '../../domain/entities/daily_plan.dart';

class DailyPlanModel extends DailyPlan {
  const DailyPlanModel({
    required super.id,
    required super.title,
    required super.color,
    required super.isDone,
    required super.items,
    required super.createdAt,
  });

  factory DailyPlanModel.fromJson(Map<String, dynamic> json) => DailyPlanModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title: json['title']?.toString() ?? '',
    color: DailyPlanColor.fromApi(json['color']?.toString()),
    isDone: json['is_done'] == true,
    items: (json['items'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => DailyPlanItemModel.fromJson(item.cast<String, dynamic>()),
        )
        .toList(),
    createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
  );
}

class DailyPlanItemModel extends DailyPlanItem {
  const DailyPlanItemModel({
    required super.id,
    required super.title,
    required super.isDone,
  });

  factory DailyPlanItemModel.fromJson(Map<String, dynamic> json) =>
      DailyPlanItemModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title']?.toString() ?? '',
        isDone: json['is_done'] == true,
      );
}
