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

  test('assignee follows todo to in-progress to done to production chain', () {
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
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.done,
        assigneeId: 7,
        context: employee,
      ),
      [TaskStatusAction.production],
    );
  });

  test('assignee cannot use tester transitions', () {
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.production,
        assigneeId: 7,
        context: employee,
      ),
      isEmpty,
    );
  });

  test('manager has no status transition', () {
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
      isEmpty,
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

  test('tester assigned to task keeps assignee transition precedence', () {
    const tester = TaskStatusPermissionContext(
      currentUserId: 9,
      activeRole: 'employee',
      testerIds: [9],
    );
    expect(
      TaskStatusPolicy.actions(
        status: TaskStatus.done,
        assigneeId: 9,
        context: tester,
      ),
      [TaskStatusAction.production],
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

  test('only admin edits all tasks and manager edits overdue deadline', () {
    const admin = TaskStatusPermissionContext(
      currentUserId: 1,
      activeRole: 'admin',
    );
    const manager = TaskStatusPermissionContext(
      currentUserId: 8,
      activeRole: 'manager',
      managerId: 8,
    );

    expect(
      TaskEditPolicy.scope(status: TaskStatus.todo, context: admin),
      TaskEditScope.full,
    );
    expect(
      TaskEditPolicy.scope(status: TaskStatus.overdue, context: manager),
      TaskEditScope.deadlineOnly,
    );
    expect(
      TaskEditPolicy.scope(status: TaskStatus.done, context: manager),
      TaskEditScope.none,
    );
  });
}
