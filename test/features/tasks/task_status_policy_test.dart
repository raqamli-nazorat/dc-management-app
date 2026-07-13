import 'package:dc_management_app/features/tasks/domain/entities/task.dart';
import 'package:dc_management_app/features/tasks/domain/task_status_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const employee = TaskStatusPermissionContext(
    currentUserId: 7,
    activeRole: 'employee',
    managerId: 8,
    testerIds: [9],
  );

  test('assignee follows todo to in-progress to done chain', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.todo,
        assigneeId: 7,
        context: employee,
      ),
      [TaskStatusAction.inProgress],
    );
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.inProgress,
        assigneeId: 7,
        context: employee,
      ),
      [TaskStatusAction.done],
    );
  });

  test('assignee cannot use manager or tester transitions', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.done,
        assigneeId: 7,
        context: employee,
      ),
      isEmpty,
    );
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.production,
        assigneeId: 7,
        context: employee,
      ),
      isEmpty,
    );
  });

  test('manager can move done task to production only', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.done,
        assigneeId: 10,
        context: const TaskStatusPermissionContext(
          currentUserId: 8,
          activeRole: 'manager',
          managerId: 8,
        ),
      ),
      [TaskStatusAction.production],
    );
  });

  test('tester can check or reject production task', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.production,
        assigneeId: 10,
        context: const TaskStatusPermissionContext(
          currentUserId: 9,
          activeRole: 'employee',
          testerIds: [9],
        ),
      ),
      [TaskStatusAction.checked, TaskStatusAction.rejected],
    );
  });

  test('overdue task has no status action', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.overdue,
        assigneeId: 10,
        context: const TaskStatusPermissionContext(
          currentUserId: 1,
          activeRole: 'admin',
        ),
      ),
      isEmpty,
    );
  });
}
