import 'package:equatable/equatable.dart';

import 'task.dart';

/// Bitta vazifaning to'liq detali (`GET /tasks/{id}/`) — tahrirlash formasini
/// oldindan to'ldirish uchun. Ro'yxatdagi [Task] dan farqli: forma yozadigan
/// barcha maydonlarni (narx, jarima, sprint, ijrochi id va h.k.) o'z ichiga oladi.
///
/// Diqqat: schema'da `project` writeOnly — javobda faqat `project_info` (nom)
/// bo'lishi mumkin, shuning uchun [projectId] `null` bo'lsa sahifa loyihani
/// `project-shorts` ro'yxatidan nom bo'yicha topadi.
class TaskDetail extends Equatable {
  const TaskDetail({
    required this.id,
    required this.projectId,
    required this.projectInfo,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.type,
    required this.assigneeId,
    required this.assigneeName,
    required this.assigneePosition,
    required this.assigneeAvatar,
    required this.positionId,
    required this.positionName,
    required this.createdByName,
    required this.deadline,
    required this.taskPrice,
    required this.penaltyPercentage,
    required this.sprint,
    required this.estimatedMinutes,
    required this.rejectionReason,
    required this.rejectionFiles,
  });

  final int id;
  final int? projectId;
  final String projectInfo;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskType? type;
  final int? assigneeId;
  final String assigneeName;
  final String assigneePosition;
  final String assigneeAvatar;
  final int? positionId;
  final String positionName;

  /// Topshiruvchi (`created_by_info.username`) — Batafsil sahifasida.
  final String createdByName;
  final DateTime? deadline;

  /// Decimal string ("150000.00") — forma butun qismini ko'rsatadi.
  final String taskPrice;
  final String penaltyPercentage;
  final int? sprint;
  final int? estimatedMinutes;

  /// Rad etish sababi + skrinshotlari (`rejection_reason`/`rejection_files`).
  final String rejectionReason;
  final List<String> rejectionFiles;

  @override
  List<Object?> get props => [
    id,
    projectId,
    projectInfo,
    title,
    description,
    status,
    priority,
    type,
    assigneeId,
    assigneeName,
    assigneePosition,
    assigneeAvatar,
    positionId,
    positionName,
    createdByName,
    deadline,
    taskPrice,
    penaltyPercentage,
    sprint,
    estimatedMinutes,
    rejectionReason,
    rejectionFiles,
  ];
}

/// Vazifaga biriktirilgan fayl (`GET /task-attachments/?task=`).
class TaskAttachmentInfo extends Equatable {
  const TaskAttachmentInfo({required this.id, required this.fileUrl});

  final int id;
  final String fileUrl;

  /// URL'dan fayl nomi (chip yozuvi uchun).
  String get name {
    final segments = Uri.tryParse(fileUrl)?.pathSegments ?? const [];
    return segments.isEmpty ? fileUrl : segments.last;
  }

  @override
  List<Object?> get props => [id, fileUrl];
}
