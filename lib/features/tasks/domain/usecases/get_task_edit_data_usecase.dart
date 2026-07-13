import '../../../../core/usecases/usecase.dart';
import '../entities/task_detail.dart';
import '../repository/task_repository.dart';

/// Tahrirlash formasi uchun vazifa detali + biriktirilgan fayllar (parallel).
typedef TaskEditData = ({
  TaskDetail detail,
  List<TaskAttachmentInfo> attachments,
});

class GetTaskEditDataUseCase implements UseCase<TaskEditData, int> {
  const GetTaskEditDataUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<TaskEditData> call(int taskId) async {
    final results = await Future.wait([
      _repository.getTaskDetail(taskId),
      _repository.getTaskAttachments(taskId),
    ]);
    return (
      detail: results[0] as TaskDetail,
      attachments: results[1] as List<TaskAttachmentInfo>,
    );
  }
}
