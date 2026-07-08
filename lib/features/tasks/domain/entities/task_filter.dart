import 'package:equatable/equatable.dart';

import 'task.dart';

/// Vazifalar ro'yxati filtri (`GET /tasks/` query paramlari). Har bir maydon
/// bitta tanlov (dizayn bir qiymatli) — bo'sh bo'lsa param yuborilmaydi.
///
/// Maydon → param moslashuvi:
/// - [projectIds] → `project`     (Loyiha — ko'p tanlov)
/// - [createdByIds] → `created_by` (Muallif — ko'p tanlov)
/// - [assigneeIds] → `assignee`    (Xodim — ko'p tanlov)
/// - [status] → `status`        (Holati)
/// - [priority] → `priority`    (Darajasi)
/// - [type] → `type`            (Turi)
/// - [deadlineFrom]/[deadlineTo] → `deadline_from`/`deadline_to` (Muddat oralig'i)
/// - [search] → `search`        (qidiruv matni — sarlavhadagi qidiruv paneli)
class TaskFilter extends Equatable {
  const TaskFilter({
    this.projectIds = const {},
    this.createdByIds = const {},
    this.assigneeIds = const {},
    this.status,
    this.priority,
    this.type,
    this.deadlineFrom,
    this.deadlineTo,
    this.search = '',
  });

  final Set<int> projectIds;
  final Set<int> createdByIds;
  final Set<int> assigneeIds;
  final TaskStatus? status;
  final TaskPriority? priority;
  final TaskType? type;
  final DateTime? deadlineFrom;
  final DateTime? deadlineTo;
  final String search;

  static const empty = TaskFilter();

  /// Qidiruvdan tashqari biror filtr faol — sarlavhadagi filtr tugmasi ustidagi
  /// nuqta shu bo'yicha ko'rsatiladi.
  bool get hasActiveFilters =>
      projectIds.isNotEmpty ||
      createdByIds.isNotEmpty ||
      assigneeIds.isNotEmpty ||
      status != null ||
      priority != null ||
      type != null ||
      deadlineFrom != null ||
      deadlineTo != null;

  /// Qidiruv matnini o'zgartirib nusxa qaytaradi (boshqa filtrlar saqlanadi).
  TaskFilter copyWithSearch(String search) => TaskFilter(
    projectIds: projectIds,
    createdByIds: createdByIds,
    assigneeIds: assigneeIds,
    status: status,
    priority: priority,
    type: type,
    deadlineFrom: deadlineFrom,
    deadlineTo: deadlineTo,
    search: search,
  );

  @override
  List<Object?> get props => [
    projectIds,
    createdByIds,
    assigneeIds,
    status,
    priority,
    type,
    deadlineFrom,
    deadlineTo,
    search,
  ];
}
