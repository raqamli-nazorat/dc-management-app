import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_document.dart';
import '../../domain/entities/project_filter.dart';
import '../../domain/entities/project_form.dart';
import '../../domain/repository/project_repository.dart';
import '../data_sources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  const ProjectRepositoryImpl(this._remote);

  final ProjectRemoteDataSource _remote;

  @override
  Future<ProjectPage> getProjects({
    int page = 1,
    ProjectFilter filter = ProjectFilter.empty,
  }) => _guard(() => _remote.getProjects(page: page, filter: filter));

  @override
  Future<Project> createProject(ProjectForm form) =>
      _guard(() => _remote.createProject(form));

  @override
  Future<Project> getProject(int id) => _guard(() => _remote.getProject(id));

  @override
  Future<Project> updateProject(int id, ProjectForm form) =>
      _guard(() => _remote.updateProject(id, form));

  @override
  Future<Project> patchProject(int id, ProjectPatch patch) =>
      _guard(() => _remote.patchProject(id, patch));

  @override
  Future<void> deleteProject(int id) => _guard(() => _remote.deleteProject(id));

  @override
  Future<List<Project>> getTrashedProjects() =>
      _guard(_remote.getTrashedProjects);

  @override
  Future<void> hardDeleteProject(int id) =>
      _guard(() => _remote.hardDeleteProject(id));

  @override
  Future<Project> restoreProject(int id) =>
      _guard(() => _remote.restoreProject(id));

  @override
  Future<ProjectDocumentPage> getProjectDocuments({
    int page = 1,
    int? projectId,
  }) => _guard(
    () => _remote.getProjectDocuments(page: page, projectId: projectId),
  );

  @override
  Future<ProjectDocument> createProjectDocument(ProjectDocument document) =>
      _guard(() => _remote.createProjectDocument(document));

  @override
  Future<ProjectDocument> getProjectDocument(int id) =>
      _guard(() => _remote.getProjectDocument(id));

  @override
  Future<ProjectDocument> updateProjectDocument(
    int id,
    ProjectDocument document,
  ) => _guard(() => _remote.updateProjectDocument(id, document));

  @override
  Future<ProjectDocument> patchProjectDocument(
    int id,
    ProjectDocument document,
  ) => _guard(() => _remote.patchProjectDocument(id, document));

  @override
  Future<void> deleteProjectDocument(int id) =>
      _guard(() => _remote.deleteProjectDocument(id));

  @override
  Future<ProjectPage> getProjectShorts({
    int page = 1,
    String search = '',
    ProjectStatus? status,
    String? prefix,
  }) => _guard(
    () => _remote.getProjectShorts(
      page: page,
      search: search,
      status: status,
      prefix: prefix,
    ),
  );

  @override
  Future<Project> getProjectShort(int id) =>
      _guard(() => _remote.getProjectShort(id));

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
