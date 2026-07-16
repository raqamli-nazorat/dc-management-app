import 'package:dc_management_app/core/network/response_mapper.dart';
import 'package:dc_management_app/features/statistics/data/models/statistics_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('asMap/asList do not throw on non-Map bodies', () {
    expect(ResponseMapper.asMap(null), isEmpty);
    expect(ResponseMapper.asMap('xato'), isEmpty);
    expect(ResponseMapper.asMap([1, 2]), isEmpty);
    expect(ResponseMapper.asList('xato'), isEmpty);
    expect(ResponseMapper.asMap({'data': null}), {'data': null});
  });

  test('PeriodStatisticsModel tolerates null / missing / string numbers', () {
    final empty = PeriodStatisticsModel.fromJson({});
    expect(empty.tasks.total, 0);
    expect(empty.projects.completionRate, 0.0);
    expect(empty.meetings.attended, 0);

    final nulls = PeriodStatisticsModel.fromJson({
      'projects': null,
      'tasks': {'total': null, 'todo': '7', 'completion_rate': '85.5'},
      'meetings': 'kutilmagan',
    });
    expect(nulls.tasks.total, 0);
    expect(nulls.tasks.todo, 7);
    expect(nulls.tasks.completionRate, 85.5);
    expect(nulls.meetings.total, 0);
    expect(nulls.projects.total, 0);
  });
}
