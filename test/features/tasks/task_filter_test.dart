import 'package:dc_management_app/features/tasks/domain/entities/task.dart';
import 'package:dc_management_app/features/tasks/domain/entities/task_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskFilter', () {
    test('empty filter has no active filters and no search', () {
      expect(TaskFilter.empty.hasActiveFilters, isFalse);
      expect(TaskFilter.empty.search, isEmpty);
    });

    test('any non-search field marks filter active', () {
      expect(const TaskFilter(projectIds: {1}).hasActiveFilters, isTrue);
      expect(const TaskFilter(priority: TaskPriority.high).hasActiveFilters,
          isTrue);
      expect(TaskFilter(deadlineFrom: DateTime(2026)).hasActiveFilters, isTrue);
    });

    test('empty id sets do not mark filter active', () {
      expect(const TaskFilter(projectIds: {}).hasActiveFilters, isFalse);
    });

    test('search alone does not mark filter active', () {
      expect(const TaskFilter(search: 'abc').hasActiveFilters, isFalse);
    });

    test('copyWithSearch keeps other fields, replaces search', () {
      const base =
          TaskFilter(projectIds: {5}, assigneeIds: {9, 10}, search: 'old');
      final next = base.copyWithSearch('new');
      expect(next.search, 'new');
      expect(next.projectIds, {5});
      expect(next.assigneeIds, {9, 10});
      expect(next.hasActiveFilters, isTrue);
    });
  });

  group('enum apiValue', () {
    test('priority maps to API strings, unknown to null', () {
      expect(TaskPriority.low.apiValue, 'low');
      expect(TaskPriority.critical.apiValue, 'critical');
      expect(TaskPriority.unknown.apiValue, isNull);
    });

    test('type round-trips through API strings (extra, not addition)', () {
      for (final t in TaskType.values) {
        expect(TaskType.fromApi(t.apiValue), t);
      }
      expect(TaskType.extra.apiValue, 'extra');
      expect(TaskType.fromApi('unknown'), isNull);
    });
  });
}
