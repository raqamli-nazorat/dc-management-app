/// Yangi vazifa yaratish uchun forma yuki (`POST /tasks/`).
///
/// Ixtiyoriy maydonlar `null` bo'lsa so'rovga qo'shilmaydi (data qatlamida).
/// [priority]/[type] — API stringlari (`low`/`bug`/...), enum emas.
class NewTask {
  const NewTask({
    required this.project,
    required this.title,
    required this.description,
    required this.deadline,
    this.priority,
    this.type,
    this.assignee,
    this.position,
    this.taskPrice,
    this.penaltyPercentage,
    this.sprint,
    this.estimatedMinutes,
  });

  final int project;
  final String title;
  final String description;
  final DateTime deadline;
  final String? priority;
  final String? type;
  final int? assignee;
  final int? position;
  final String? taskPrice;
  final String? penaltyPercentage;
  final int? sprint;
  final int? estimatedMinutes;
}
