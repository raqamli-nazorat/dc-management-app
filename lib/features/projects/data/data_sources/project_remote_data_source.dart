import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_document.dart';
import '../../domain/entities/project_filter.dart';
import '../../domain/entities/project_form.dart';
import '../models/project_document_model.dart';
import '../models/project_model.dart';

abstract interface class ProjectRemoteDataSource {
  Future<ProjectPage> getProjects({int page, ProjectFilter filter});

  Future<ProjectModel> createProject(ProjectForm form);

  Future<ProjectModel> getProject(int id);

  Future<ProjectModel> updateProject(int id, ProjectForm form);

  Future<ProjectModel> patchProject(int id, ProjectPatch patch);

  Future<void> deleteProject(int id);

  Future<List<ProjectModel>> getTrashedProjects();

  Future<void> hardDeleteProject(int id);

  Future<ProjectModel> restoreProject(int id);

  Future<ProjectDocumentPage> getProjectDocuments({int page, int? projectId});

  Future<ProjectDocumentModel> createProjectDocument(ProjectDocument document);

  Future<ProjectDocumentModel> getProjectDocument(int id);

  Future<ProjectDocumentModel> updateProjectDocument(
    int id,
    ProjectDocument document,
  );

  Future<ProjectDocumentModel> patchProjectDocument(
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

  Future<ProjectModel> getProjectShort(int id);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  const ProjectRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<ProjectPage> getProjects({
    int page = 1,
    ProjectFilter filter = ProjectFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projects,
        queryParameters: {'page': page, ..._projectFilterParams(filter)},
      );
      return _projectPage(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> createProject(ProjectForm form) async {
    try {
      final response = await _client.post(
        ApiConstants.projects,
        data: _projectFormData(form),
      );
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> getProject(int id) async {
    try {
      final response = await _client.get(ApiConstants.projectById(id));
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> updateProject(int id, ProjectForm form) async {
    try {
      final response = await _client.put(
        ApiConstants.projectById(id),
        data: _projectFormData(form),
      );
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> patchProject(int id, ProjectPatch patch) async {
    try {
      final response = await _client.patch(
        ApiConstants.projectById(id),
        data: _projectPatchData(patch),
      );
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> deleteProject(int id) async {
    try {
      await _client.delete(ApiConstants.projectById(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<ProjectModel>> getTrashedProjects() async {
    try {
      final response = await _client.get(ApiConstants.projectsTrash);
      return _projectList(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> hardDeleteProject(int id) async {
    try {
      await _client.delete(ApiConstants.projectHardDelete(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> restoreProject(int id) async {
    try {
      final response = await _client.post(ApiConstants.projectRestore(id));
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectDocumentPage> getProjectDocuments({
    int page = 1,
    int? projectId,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectDocuments,
        queryParameters: {'page': page, 'project': ?projectId},
      );
      return _documentPage(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectDocumentModel> createProjectDocument(
    ProjectDocument document,
  ) async {
    try {
      final response = await _client.post(
        ApiConstants.projectDocuments,
        data: _documentData(document),
      );
      return _document(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectDocumentModel> getProjectDocument(int id) async {
    try {
      final response = await _client.get(ApiConstants.projectDocumentById(id));
      return _document(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectDocumentModel> updateProjectDocument(
    int id,
    ProjectDocument document,
  ) async {
    try {
      final response = await _client.put(
        ApiConstants.projectDocumentById(id),
        data: _documentData(document),
      );
      return _document(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectDocumentModel> patchProjectDocument(
    int id,
    ProjectDocument document,
  ) async {
    try {
      final response = await _client.patch(
        ApiConstants.projectDocumentById(id),
        data: _documentData(document),
      );
      return _document(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> deleteProjectDocument(int id) async {
    try {
      await _client.delete(ApiConstants.projectDocumentById(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> uploadProjectDocument(int projectId, String filePath) async {
    try {
      // Schema'da ProjectDocument faqat {project, name, value} (string) —
      // fayl maydoni hujjatlashtirilmagan. `file` binariy sifatida qo'shib
      // yuboriladi (backend qabul qilsa saqlaydi, aks holda e'tiborsiz
      // qoladi); `name`/`value` — fayl nomi. Kontrakt aniqlashsa moslanadi.
      final fileName = filePath.split(RegExp(r'[\\/]')).last;
      final formData = FormData.fromMap({
        'project': projectId,
        'name': fileName,
        'value': fileName,
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      await _client.post(ApiConstants.projectDocuments, data: formData);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectPage> getProjectShorts({
    int page = 1,
    String search = '',
    ProjectStatus? status,
    String? prefix,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.projectShorts,
        queryParameters: {
          'page': page,
          if (search.trim().isNotEmpty) 'search': search.trim(),
          if (status?.apiValue != null) 'status': status!.apiValue,
          if (prefix?.trim().isNotEmpty ?? false) 'prefix': prefix!.trim(),
        },
      );
      return _projectPage(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProjectModel> getProjectShort(int id) async {
    try {
      final response = await _client.get(ApiConstants.projectShortById(id));
      return _project(response.data);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  ProjectModel _project(dynamic data) =>
      ProjectModel.fromJson(ResponseMapper.asMap(data));

  List<ProjectModel> _projectList(dynamic data) {
    final items = ResponseMapper.asList(data)
        .whereType<Map>()
        .map((e) => ProjectModel.fromJson(e.cast<String, dynamic>()))
        .toList();
    if (items.isNotEmpty) return items;
    final body = ResponseMapper.asMap(data);
    if (body['id'] != null) return [ProjectModel.fromJson(body)];
    return const [];
  }

  ProjectPage _projectPage(dynamic data) {
    final body = ResponseMapper.asMap(data);
    final items = _projectList(data);
    return (
      items: items,
      totalCount: (body['count'] as num?)?.toInt() ?? items.length,
      hasMore: body['next'] != null,
    );
  }

  ProjectDocumentModel _document(dynamic data) =>
      ProjectDocumentModel.fromJson(ResponseMapper.asMap(data));

  ProjectDocumentPage _documentPage(dynamic data) {
    final body = ResponseMapper.asMap(data);
    final items = ResponseMapper.asList(data)
        .whereType<Map>()
        .map((e) => ProjectDocumentModel.fromJson(e.cast<String, dynamic>()))
        .toList();
    return (
      items: items,
      totalCount: (body['count'] as num?)?.toInt() ?? items.length,
      hasMore: body['next'] != null,
    );
  }

  Map<String, dynamic> _projectFilterParams(ProjectFilter filter) => {
    if (filter.search.trim().isNotEmpty) 'search': filter.search.trim(),
    if (filter.status?.apiValue != null) 'status': filter.status!.apiValue,
    if (filter.managerId != null) 'manager': filter.managerId,
    if (filter.employeeId != null) 'employee': filter.employeeId,
    if (filter.deadlineFrom != null)
      'deadline_gte': filter.deadlineFrom!.toIso8601String(),
    if (filter.deadlineTo != null)
      'deadline_lte': filter.deadlineTo!.toIso8601String(),
    if (filter.createdFrom != null)
      'created_at_gte': filter.createdFrom!.toIso8601String(),
    if (filter.createdTo != null)
      'created_at_lte': filter.createdTo!.toIso8601String(),
    if (filter.isDeleted != null) 'is_deleted': filter.isDeleted,
    if (filter.ordering?.trim().isNotEmpty ?? false)
      'ordering': filter.ordering!.trim(),
  };

  Map<String, dynamic> _projectFormData(ProjectForm form) => {
    'prefix': form.prefix,
    'title': form.title,
    if (form.description != null) 'description': form.description,
    'manager': form.manager,
    'testers': form.testers,
    'employees': form.employees,
    'deadline': form.deadline.toIso8601String(),
    if (form.projectPrice != null) 'project_price': form.projectPrice,
    if (form.penaltyPercentage != null)
      'penalty_percentage': form.penaltyPercentage,
    if (form.status?.apiValue != null) 'status': form.status!.apiValue,
    if (form.isHidden != null) 'is_hidden': form.isHidden,
  };

  Map<String, dynamic> _projectPatchData(ProjectPatch patch) => {
    if (patch.prefix != null) 'prefix': patch.prefix,
    if (patch.title != null) 'title': patch.title,
    if (patch.description != null) 'description': patch.description,
    if (patch.manager != null) 'manager': patch.manager,
    if (patch.testers != null) 'testers': patch.testers,
    if (patch.employees != null) 'employees': patch.employees,
    if (patch.deadline != null) 'deadline': patch.deadline!.toIso8601String(),
    if (patch.projectPrice != null) 'project_price': patch.projectPrice,
    if (patch.penaltyPercentage != null)
      'penalty_percentage': patch.penaltyPercentage,
    if (patch.status?.apiValue != null) 'status': patch.status!.apiValue,
    if (patch.isHidden != null) 'is_hidden': patch.isHidden,
  };

  Map<String, dynamic> _documentData(ProjectDocument document) => {
    'project': document.project,
    'name': document.name,
    'value': document.value,
  };
}
