import '../../../../core/usecases/usecase.dart';
import '../entities/task_form_options.dart';
import '../repository/task_repository.dart';

/// Loyiha ishtirokchilarini (Topshiruvchi tanlovi) oladi (`GET /projects/{id}/`).
/// Param — loyiha id'si.
class GetProjectMembersUseCase implements UseCase<List<ProjectMember>, int> {
  const GetProjectMembersUseCase(this._repository);

  final TaskRepository _repository;

  @override
  Future<List<ProjectMember>> call(int projectId) =>
      _repository.getProjectMembers(projectId);
}
