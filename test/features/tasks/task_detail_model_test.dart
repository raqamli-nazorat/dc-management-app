import 'package:dc_management_app/features/tasks/data/models/task_detail_model.dart';
import 'package:dc_management_app/features/tasks/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TaskDetailModel parses detail response for edit prefill', () {
    final model = TaskDetailModel.fromJson({
      'id': 7,
      'project_info': 'CRM tizimi', // writeOnly `project` javobda yo'q
      'title': 'Login bug',
      'description': 'Fix it',
      'priority': 'high',
      'type': 'extra',
      'assignee_info': {'id': 3, 'username': 'Ali', 'position': 'Dev'},
      'position_info': {'id': 5, 'name': 'Backend'},
      'deadline': '2026-07-20T23:59:00',
      'task_price': '150000.00',
      'penalty_percentage': '10.00',
      'sprint': 2,
      'estimated_minutes': 90,
      'status': 'done',
      'created_by_info': {'id': 9, 'username': 'Vali'},
      'rejection_reason': 'Xato bor',
      'rejection_files': [
        {'id': 1, 'file': 'https://x/y.png'},
      ],
    });

    expect(model.id, 7);
    expect(model.projectId, isNull); // faqat nom bor — sahifa nom bo'yicha topadi
    expect(model.projectInfo, 'CRM tizimi');
    expect(model.priority, TaskPriority.high);
    expect(model.type, TaskType.extra);
    expect(model.assigneeId, 3);
    expect(model.positionId, 5);
    expect(model.taskPrice, '150000.00');
    expect(model.sprint, 2);
    expect(model.estimatedMinutes, 90);
    expect(model.status, TaskStatus.done);
    expect(model.createdByName, 'Vali');
    expect(model.rejectionReason, 'Xato bor');
    expect(model.rejectionFiles, ['https://x/y.png']);
  });

  test('TaskDetailModel takes project id from nested project_info', () {
    final model = TaskDetailModel.fromJson({
      'id': 1,
      'project_info': {'id': 42, 'name': 'CRM'},
      'title': 't',
    });
    expect(model.projectId, 42);
    expect(model.projectInfo, 'CRM');
  });
}
