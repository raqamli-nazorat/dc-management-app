/// Vazifa forma yuki (`POST /tasks/` / `PATCH /tasks/{id}/`).
///
/// Ixtiyoriy maydonlar `null` bo'lsa so'rovga qo'shilmaydi (data qatlamida).
/// [priority]/[type] — API stringlari (`low`/`bug`/...), enum emas.
/// [project] tahrirlashda `null` bo'lishi mumkin (o'zgartirilmagan — PATCH'da
/// yuborilmaydi); yaratishda sahifa uni majburiy tekshiradi.
class NewTask {
  const NewTask({
    this.project,
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
    this.deadlineOnly = false,
  });

  final int? project;
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

  /// Manager overdue taskda faqat shu PATCH tanasi yuboriladi.
  final bool deadlineOnly;
}
