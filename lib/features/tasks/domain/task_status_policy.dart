import 'package:equatable/equatable.dart';

import 'entities/task.dart';

/// Detail sahifasida ko'rsatiladigan status actionlari.
enum TaskStatusAction { inProgress, done, production, checked, rejected }

/// Vazifa tahrirlash darajasi. Status o'zgartirishdan alohida saqlanadi.
enum TaskEditScope { none, deadlineOnly, full }

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

    // Tester o'ziga biriktirilgan bo'lsa ham, ijrochi oqimi ustuvor.
    if (assigneeId == context.currentUserId) {
      return switch (status) {
        TaskStatus.todo => const [TaskStatusAction.inProgress],
        TaskStatus.inProgress => const [TaskStatusAction.done],
        TaskStatus.done => const [TaskStatusAction.production],
        _ => const [],
      };
    }

    // Overdue task status swipe olmaydi; edit huquqini alohida policy belgilaydi.
    if (status == TaskStatus.overdue) return const [];

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

/// Client-side edit matrix. Backend authorization yakuniy manba bo'lib qoladi.
class TaskEditPolicy {
  const TaskEditPolicy._();

  static TaskEditScope scope({
    required TaskStatus status,
    required TaskStatusPermissionContext? context,
  }) {
    if (context == null) return TaskEditScope.none;
    if (context.activeRole.toLowerCase() == 'admin') {
      return TaskEditScope.full;
    }
    if (status == TaskStatus.overdue &&
        context.managerId == context.currentUserId) {
      return TaskEditScope.deadlineOnly;
    }
    return TaskEditScope.none;
  }

  static bool canUpdate({
    required TaskStatus status,
    required TaskStatusPermissionContext? context,
    required bool deadlineOnly,
  }) => switch (scope(status: status, context: context)) {
    TaskEditScope.full => !deadlineOnly,
    TaskEditScope.deadlineOnly => deadlineOnly,
    TaskEditScope.none => false,
  };
}
