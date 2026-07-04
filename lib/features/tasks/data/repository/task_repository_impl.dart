import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repository/task_repository.dart';
import '../data_sources/task_remote_data_source.dart';

/// [TaskRepository] implementatsiyasi — data source `Exception`larini domen
/// `Failure`lariga aylantiradi.
class TaskRepositoryImpl implements TaskRepository {
  const TaskRepositoryImpl(this._remote);

  final TaskRemoteDataSource _remote;

  @override
  Future<List<Task>> getTasks() => _guard(() => _remote.getTasks());

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
