import '../entities/new_task.dart';
import '../entities/task.dart';
import '../entities/task_detail.dart';
import '../entities/task_filter.dart';
import '../entities/task_form_options.dart';

/// Vazifalar domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class TaskRepository {
  /// Vazifalar sahifasi (`GET /tasks/?page=` + filtr).
  Future<TaskPage> getTasks({int page, TaskFilter filter});

  /// Lavozimlar (vazifa "Kimlar uchun" / filtr "Topshiruvchi" tanlovi).
  Future<List<Position>> getPositions();

  /// Barcha foydalanuvchilar (filtr "Muallif"/"Xodim" tanlovi).
  Future<List<UserShort>> getUsers();

  Future<List<UserShort>> getManagers();

  /// Qisqa loyihalar (vazifa "Loyiha" tanlovi).
  Future<List<ProjectShort>> getProjectShorts();

  /// Loyiha ishtirokchilari (Topshiruvchi tanlovi).
  Future<List<ProjectMember>> getProjectMembers(int projectId);

  /// Vazifa yaratadi (`POST /tasks/`), yangi `id` ni qaytaradi.
  Future<int> createTask(NewTask task);

  /// Vazifani yangilaydi (`PATCH /tasks/{id}/`).
  Future<void> updateTask(int id, NewTask task);

  /// Bitta vazifa detali (`GET /tasks/{id}/`) — tahrirlash formasi uchun.
  Future<TaskDetail> getTaskDetail(int id);

  /// Vazifaga biriktirilgan fayllar (`GET /task-attachments/?task=`).
  Future<List<TaskAttachmentInfo>> getTaskAttachments(int taskId);

  /// Vazifaga bitta fayl biriktiradi (`POST /task-attachments/`).
  Future<void> uploadAttachment(int taskId, String filePath);

  /// Biriktirilgan faylni o'chiradi (`DELETE /task-attachments/{id}/`).
  Future<void> deleteAttachment(int id);

  /// Vazifa holatini o'zgartiradi (`PATCH /tasks/{id}/change-status/`).
  Future<void> changeTaskStatus(int id, String status, {String? reason});

  /// Rad etish skrinshotini yuklaydi (`POST /task-rejection-files/`).
  Future<void> uploadRejectionFile(int taskId, String filePath);

  /// Vazifani o'chiradi (`DELETE /tasks/{id}/`).
  Future<void> deleteTask(int id);
}
