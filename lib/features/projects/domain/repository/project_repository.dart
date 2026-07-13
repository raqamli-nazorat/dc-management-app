import '../entities/project.dart';
import '../entities/project_document.dart';
import '../entities/project_filter.dart';
import '../entities/project_form.dart';

abstract interface class ProjectRepository {
  Future<ProjectPage> getProjects({int page, ProjectFilter filter});

  Future<Project> createProject(ProjectForm form);

  Future<Project> getProject(int id);

  Future<Project> updateProject(int id, ProjectForm form);

  Future<Project> patchProject(int id, ProjectPatch patch);

  Future<void> deleteProject(int id);

  Future<List<Project>> getTrashedProjects();

  Future<void> hardDeleteProject(int id);

  Future<Project> restoreProject(int id);

  Future<ProjectDocumentPage> getProjectDocuments({int page, int? projectId});

  Future<ProjectDocument> createProjectDocument(ProjectDocument document);

  Future<ProjectDocument> getProjectDocument(int id);

  Future<ProjectDocument> updateProjectDocument(
    int id,
    ProjectDocument document,
  );

  Future<ProjectDocument> patchProjectDocument(
    int id,
    ProjectDocument document,
  );

  Future<void> deleteProjectDocument(int id);

  /// Loyihaga fayl biriktiradi (multipart `POST /project-documents/`).
  Future<void> uploadProjectDocument(int projectId, String filePath);

  Future<ProjectPage> getProjectShorts({
    int page,
    String search,
    ProjectStatus? status,
    String? prefix,
  });

  Future<Project> getProjectShort(int id);
}
