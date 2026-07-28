import 'package:dc_management_app/features/daily_plans/data/models/daily_plan_model.dart';
import 'package:dc_management_app/features/daily_plans/domain/entities/daily_plan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a daily plan and its child items tolerantly', () {
    final plan = DailyPlanModel.fromJson({
      'id': 3,
      'title': 'Bugungi reja',
      'color': 'green',
      'is_done': true,
      'created_at': '2026-07-22T08:00:00Z',
      'items': [
        {'id': 4, 'title': 'Hisobot', 'is_done': false},
      ],
    });

    expect(plan.color, DailyPlanColor.green);
    expect(plan.isDone, isTrue);
    expect(plan.items.single.title, 'Hisobot');
    expect(plan.items.single.isDone, isFalse);
  });
}
