import 'package:equatable/equatable.dart';

import 'entities/task.dart';

/// Detail sahifasida ko'rsatiladigan status actionlari.
enum TaskStatusAction { inProgress, done, production, checked, rejected }

/// Task detail uchun authorization konteksti.
class TaskStatusPermissionContext extends Equatable {
  const TaskStatusPermissionContext({
    required this.currentUserId,
    required this.activeRole,
    this.managerId,
    this.testerIds = const [],
  });

  final int currentUserId;
  final String activeRole;
  final int? managerId;
  final List<int> testerIds;

  @override
  List<Object?> get props => [currentUserId, activeRole, managerId, testerIds];
}

/// Client-side action matrix. Backend authorization baribir yakuniy manba.
class TaskStatusPolicy {
  const TaskStatusPolicy._();

  static List<TaskStatusAction> actions({
    required TaskStatus status,
    required int? assigneeId,
    required TaskStatusPermissionContext? context,
  }) {
    if (context == null) return const [];

    // Manager/tester o'ziga biriktirilgan taskda faqat assignee oqimidan
    // foydalanadi.
    if (assigneeId == context.currentUserId) {
      return switch (status) {
        TaskStatus.todo => const [TaskStatusAction.inProgress],
        TaskStatus.inProgress => const [TaskStatusAction.done],
        _ => const [],
      };
    }

    // Overdue task faqat deadline edit oqimi orqali tuzatiladi.
    if (status == TaskStatus.overdue) return const [];

    if (status == TaskStatus.done &&
        context.managerId == context.currentUserId) {
      return const [TaskStatusAction.production];
    }

    if (status == TaskStatus.production &&
        context.testerIds.contains(context.currentUserId)) {
      return const [TaskStatusAction.checked, TaskStatusAction.rejected];
    }

    return const [];
  }

  static TaskStatus target(TaskStatusAction action) => switch (action) {
    TaskStatusAction.inProgress => TaskStatus.inProgress,
    TaskStatusAction.done => TaskStatus.done,
    TaskStatusAction.production => TaskStatus.production,
    TaskStatusAction.checked => TaskStatus.checked,
    TaskStatusAction.rejected => TaskStatus.rejected,
  };

  static bool canChange({
    required TaskStatus currentStatus,
    required TaskStatus targetStatus,
    required int? assigneeId,
    required TaskStatusPermissionContext? context,
  }) {
    return actions(
      status: currentStatus,
      assigneeId: assigneeId,
      context: context,
    ).map(target).contains(targetStatus);
  }
}
