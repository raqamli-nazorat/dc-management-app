import '../../../../core/usecases/usecase.dart';
import '../../../../core/usecases/no_params.dart';
import '../entities/project.dart';
import '../entities/project_document.dart';
import '../entities/project_filter.dart';
import '../entities/project_form.dart';
import '../repository/project_repository.dart';

typedef GetProjectsParams = ({int page, ProjectFilter filter});
typedef ProjectFormParams = ({int id, ProjectForm form});
typedef ProjectPatchParams = ({int id, ProjectPatch patch});
typedef GetProjectDocumentsParams = ({int page, int? projectId});
typedef ProjectDocumentParams = ({int id, ProjectDocument document});
typedef GetProjectShortsParams = ({
  int page,
  String search,
  ProjectStatus? status,
  String? prefix,
});

class GetProjectsUseCase implements UseCase<ProjectPage, GetProjectsParams> {
  const GetProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectPage> call(GetProjectsParams params) =>
      _repository.getProjects(page: params.page, filter: params.filter);
}

class CreateProjectUseCase implements UseCase<Project, ProjectForm> {
  const CreateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(ProjectForm params) => _repository.createProject(params);
}

class GetProjectUseCase implements UseCase<Project, int> {
  const GetProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(int params) => _repository.getProject(params);
}

class UpdateProjectUseCase implements UseCase<Project, ProjectFormParams> {
  const UpdateProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(ProjectFormParams params) =>
      _repository.updateProject(params.id, params.form);
}

class PatchProjectUseCase implements UseCase<Project, ProjectPatchParams> {
  const PatchProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(ProjectPatchParams params) =>
      _repository.patchProject(params.id, params.patch);
}

class DeleteProjectUseCase implements UseCase<void, int> {
  const DeleteProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<void> call(int params) => _repository.deleteProject(params);
}

class GetTrashedProjectsUseCase implements UseCase<List<Project>, NoParams> {
  const GetTrashedProjectsUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<List<Project>> call(NoParams params) =>
      _repository.getTrashedProjects();
}

class HardDeleteProjectUseCase implements UseCase<void, int> {
  const HardDeleteProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<void> call(int params) => _repository.hardDeleteProject(params);
}

class RestoreProjectUseCase implements UseCase<Project, int> {
  const RestoreProjectUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(int params) => _repository.restoreProject(params);
}

class GetProjectDocumentsUseCase
    implements UseCase<ProjectDocumentPage, GetProjectDocumentsParams> {
  const GetProjectDocumentsUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectDocumentPage> call(GetProjectDocumentsParams params) =>
      _repository.getProjectDocuments(
        page: params.page,
        projectId: params.projectId,
      );
}

class CreateProjectDocumentUseCase
    implements UseCase<ProjectDocument, ProjectDocument> {
  const CreateProjectDocumentUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectDocument> call(ProjectDocument params) =>
      _repository.createProjectDocument(params);
}

class GetProjectDocumentUseCase implements UseCase<ProjectDocument, int> {
  const GetProjectDocumentUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectDocument> call(int params) =>
      _repository.getProjectDocument(params);
}

class UpdateProjectDocumentUseCase
    implements UseCase<ProjectDocument, ProjectDocumentParams> {
  const UpdateProjectDocumentUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectDocument> call(ProjectDocumentParams params) =>
      _repository.updateProjectDocument(params.id, params.document);
}

class PatchProjectDocumentUseCase
    implements UseCase<ProjectDocument, ProjectDocumentParams> {
  const PatchProjectDocumentUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectDocument> call(ProjectDocumentParams params) =>
      _repository.patchProjectDocument(params.id, params.document);
}

class DeleteProjectDocumentUseCase implements UseCase<void, int> {
  const DeleteProjectDocumentUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<void> call(int params) => _repository.deleteProjectDocument(params);
}

class GetProjectShortsUseCase
    implements UseCase<ProjectPage, GetProjectShortsParams> {
  const GetProjectShortsUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<ProjectPage> call(GetProjectShortsParams params) =>
      _repository.getProjectShorts(
        page: params.page,
        search: params.search,
        status: params.status,
        prefix: params.prefix,
      );
}

class GetProjectShortUseCase implements UseCase<Project, int> {
  const GetProjectShortUseCase(this._repository);

  final ProjectRepository _repository;

  @override
  Future<Project> call(int params) => _repository.getProjectShort(params);
}
