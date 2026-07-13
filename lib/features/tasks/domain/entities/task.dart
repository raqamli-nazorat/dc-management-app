import 'package:equatable/equatable.dart';

/// Bitta sahifa natijasi: yuklangan vazifalar + umumiy son + yana sahifa
/// bor-yo'qligi (`next != null`). Cheksiz-scroll uchun bloc `hasMore` ni
/// kuzatadi, status badge uchun `totalCount` ishlatiladi.
typedef TaskPage = ({List<Task> items, int totalCount, bool hasMore});

/// Vazifa muhimligi (`priority`). Noma'lum qiymat → [unknown].
enum TaskPriority {
  low,
  medium,
  high,
  critical,
  unknown;

  static TaskPriority fromApi(String? value) {
    switch (value) {
      case 'low':
        return TaskPriority.low;
      case 'medium':
        return TaskPriority.medium;
      case 'high':
        return TaskPriority.high;
      case 'critical':
        return TaskPriority.critical;
      default:
        return TaskPriority.unknown;
    }
  }

  /// So'rov paramlari uchun API string'i (`unknown` → `null`).
  String? get apiValue => switch (this) {
    TaskPriority.low => 'low',
    TaskPriority.medium => 'medium',
    TaskPriority.high => 'high',
    TaskPriority.critical => 'critical',
    TaskPriority.unknown => null,
  };
}

/// Vazifa turi (`type`, `Type225Enum`). Filtr uchun ishlatiladi. API qiymatlari:
/// `bug`/`extra`/`feature`/`research` (schema bo'yicha — vazifa yaratish
/// sahifasidagi eski `addition` emas, `extra`).
enum TaskType {
  bug,
  extra,
  feature,
  research;

  static TaskType? fromApi(String? value) => switch (value) {
    'bug' => TaskType.bug,
    'extra' => TaskType.extra,
    'feature' => TaskType.feature,
    'research' => TaskType.research,
    _ => null,
  };

  String get apiValue => switch (this) {
    TaskType.bug => 'bug',
    TaskType.extra => 'extra',
    TaskType.feature => 'feature',
    TaskType.research => 'research',
  };
}

/// Vazifa holati (`status`). Backend `Status298Enum` — 7 qiymat, kartadagi
/// nuqta rangi shu bo'yicha tanlanadi. Noma'lum qiymat → [unknown].
enum TaskStatus {
  todo, // Qilinishi kerak
  inProgress, // Jarayonda
  overdue, // Muddati o'tgan
  done, // Bajarildi
  production, // Ishga tushirildi
  checked, // Tekshirildi
  rejected, // Rad etildi
  unknown;

  static TaskStatus fromApi(String? value) {
    switch (value) {
      case 'todo':
        return TaskStatus.todo;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'overdue':
        return TaskStatus.overdue;
      case 'done':
        return TaskStatus.done;
      case 'production':
        return TaskStatus.production;
      case 'checked':
        return TaskStatus.checked;
      case 'rejected':
        return TaskStatus.rejected;
      default:
        return TaskStatus.unknown;
    }
  }

  /// So'rov paramlari uchun API string'i (`unknown` → `null`).
  String? get apiValue => switch (this) {
    TaskStatus.todo => 'todo',
    TaskStatus.inProgress => 'in_progress',
    TaskStatus.overdue => 'overdue',
    TaskStatus.done => 'done',
    TaskStatus.production => 'production',
    TaskStatus.checked => 'checked',
    TaskStatus.rejected => 'rejected',
    TaskStatus.unknown => null,
  };
}

/// UI va status cache uchun ko'rsatiladigan tartib.
const taskFilterStatuses = [
  TaskStatus.todo,
  TaskStatus.inProgress,
  TaskStatus.done,
  TaskStatus.production,
  TaskStatus.checked,
  TaskStatus.rejected,
  TaskStatus.overdue,
];

/// Bitta vazifa (`/tasks/`).
///
/// Backend kontrakti to'liq tasdiqlanmagan — [TaskModel.fromJson] barcha
/// maydonlarni bardoshli (null-xavfsiz) o'qiydi. Bu yerda UI ko'rsatadigan
/// maydonlar to'plangan.
class Task extends Equatable {
  const Task({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.projectInfo,
    required this.status,
    required this.priority,
    required this.deadline,
    required this.estimatedMinutes,
    required this.assigneeName,
    required this.assigneePosition,
    required this.assigneeAvatar,
    this.createdByAvatar = '',
  });

  final int id;

  /// Ko'rsatiladigan kod (masalan "T1213") — bo'lmasa bo'sh.
  final String uid;

  final String title;
  final String description;

  /// Tegishli loyiha nomi (kartada ost-yozuv).
  final String projectInfo;

  final TaskStatus status;
  final TaskPriority priority;

  /// Muddat (deadline) — kartada sana + orqa sanoq.
  final DateTime? deadline;

  /// Rejalashtirilgan vaqt (daqiqada) — kartada "Xh Ymin".
  final int? estimatedMinutes;

  /// Ijrochi (assignee) ismi + lavozimi + avatar.
  final String assigneeName;
  final String assigneePosition;
  final String assigneeAvatar;

  /// Muallif (`created_by_info.avatar`) — ijrochi avatari bo'lmasa fallback.
  final String createdByAvatar;

  @override
  List<Object?> get props => [
    id,
    uid,
    title,
    description,
    projectInfo,
    status,
    priority,
    deadline,
    estimatedMinutes,
    assigneeName,
    assigneePosition,
    assigneeAvatar,
    createdByAvatar,
  ];
}
