import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/new_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_form_options.dart';
import '../../domain/repository/task_repository.dart';
import '../data_sources/task_remote_data_source.dart';

/// [TaskRepository] implementatsiyasi — data source `Exception`larini domen
/// `Failure`lariga aylantiradi.
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<TaskPage> getTasks({int page = 1, TaskFilter filter = TaskFilter.empty}) =>
      _guard(() => _remote.getTasks(page: page, filter: filter));

  @override
  Future<List<Position>> getPositions() => _guard(_remote.getPositions);

  @override
  Future<List<UserShort>> getUsers() => _guard(_remote.getUsers);

  @override
  Future<List<ProjectShort>> getProjectShorts() =>
      _guard(_remote.getProjectShorts);

  @override
  Future<List<ProjectMember>> getProjectMembers(int projectId) =>
      _guard(() => _remote.getProjectMembers(projectId));

  @override
  Future<int> createTask(NewTask task) => _guard(() => _remote.createTask(task));

  @override
  Future<void> uploadAttachment(int taskId, String filePath) =>
      _guard(() => _remote.uploadAttachment(taskId, filePath));

  @override
  Future<void> deleteTask(int id) => _guard(() => _remote.deleteTask(id));

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on UnauthorizedException catch (e) {
      throw UnauthorizedFailure(e.message);
    } on ThrottleException catch (e) {
      throw ThrottleFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
