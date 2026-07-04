import '../entities/task.dart';

/// Vazifalar domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class TaskRepository {
  /// Vazifalar ro'yxati (`GET /tasks/`).
  Future<List<Task>> getTasks();
}
