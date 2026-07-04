import '../entities/task.dart';

/// Vazifalar domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class TaskRepository {
  /// Vazifalar sahifasi (`GET /tasks/?page=`).
  Future<TaskPage> getTasks({int page});
}
