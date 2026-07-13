import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/new_task.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/task_detail.dart';
import '../../domain/entities/task_filter.dart';
import '../../domain/entities/task_form_options.dart';
import '../models/task_detail_model.dart';
import '../models/task_form_option_models.dart';
import '../models/task_model.dart';

/// Vazifalar backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class TaskRemoteDataSource {
  /// Bitta sahifa (`GET /tasks/?page=` + filtr paramlari).
  Future<TaskPage> getTasks({int page, TaskFilter filter});

  /// Lavozimlar (`GET /applications/positions/?page_size=100`).
  Future<List<Position>> getPositions();

  /// Barcha foydalanuvchilar (`GET /users/all/?page_size=200`).
  Future<List<UserShort>> getUsers();

  Future<List<UserShort>> getManagers();

  /// Qisqa loyihalar (`GET /project-shorts/?page_size=200`).
  Future<List<ProjectShort>> getProjectShorts();

  /// Bitta loyiha ishtirokchilari (`GET /projects/{id}/`).
  Future<List<ProjectMember>> getProjectMembers(int projectId);

  /// Vazifa yaratadi (`POST /tasks/`) va yangi `id` ni qaytaradi.
  Future<int> createTask(NewTask task);

  /// Vazifani yangilaydi (`PATCH /tasks/{id}/` — faqat yuborilgan maydonlar).
  Future<void> updateTask(int id, NewTask task);

  /// Bitta vazifa detali (`GET /tasks/{id}/`).
  Future<TaskDetail> getTaskDetail(int id);

  /// Vazifaga biriktirilgan fayllar (`GET /task-attachments/?task=`).
  Future<List<TaskAttachmentInfo>> getTaskAttachments(int taskId);

  /// Vazifaga bitta fayl biriktiradi (multipart `POST /task-attachments/`).
  Future<void> uploadAttachment(int taskId, String filePath);

  /// Biriktirilgan faylni o'chiradi (`DELETE /task-attachments/{id}/`).
  Future<void> deleteAttachment(int id);

  /// Vazifa holatini o'zgartiradi (`PATCH /tasks/{id}/change-status/`).
  Future<void> changeTaskStatus(int id, String status, {String? reason});

  /// Rad etish skrinshotini yuklaydi (multipart `POST /task-rejection-files/`).
  Future<void> uploadRejectionFile(int taskId, String filePath);

  /// Vazifani o'chiradi (`DELETE /tasks/{id}/` — backend chiqindiga yuboradi).
  Future<void> deleteTask(int id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  const TaskRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<TaskPage> getTasks({
    int page = 1,
    TaskFilter filter = TaskFilter.empty,
  }) async {
    try {
      // Sahifalangan javob (`{count, next, previous, results}`) — sahifa
      // raqami `page` orqali, keyingi sahifa bor-yo'qligi `next != null`.
      final response = await _client.get(
        ApiConstants.tasks,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => TaskModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (
        items: items,
        totalCount: (body['count'] as num?)?.toInt() ?? items.length,
        hasMore: body['next'] != null,
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [TaskFilter] → `GET /tasks/` query paramlari (faqat to'ldirilganlari).
  Map<String, dynamic> _filterParams(TaskFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    // Ko'p tanlov → vergul bilan (schema: form, explode=false).
    if (f.projectIds.isNotEmpty) 'project': f.projectIds.join(','),
    if (f.createdByIds.isNotEmpty) 'created_by': f.createdByIds.join(','),
    if (f.assigneeIds.isNotEmpty) 'assignee': f.assigneeIds.join(','),
    if (f.status?.apiValue != null) 'status': f.status!.apiValue,
    if (f.priority?.apiValue != null) 'priority': f.priority!.apiValue,
    if (f.type != null) 'type': f.type!.apiValue,
    if (f.deadlineFrom != null)
      'deadline_from': f.deadlineFrom!.toIso8601String(),
    if (f.deadlineTo != null) 'deadline_to': f.deadlineTo!.toIso8601String(),
  };

  @override
  Future<List<Position>> getPositions() async {
    try {
      final response = await _client.get(
        ApiConstants.positions,
        queryParameters: {'page_size': 100},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => PositionModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<UserShort>> getUsers() async {
    try {
      final response = await _client.get(
        ApiConstants.usersAll,
        queryParameters: {'page_size': 200},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => UserShortModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<UserShort>> getManagers() async {
    try {
      final response = await _client.get(
        ApiConstants.users,
        queryParameters: const {'roles': 'employee'},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => e.cast<String, dynamic>())
          .where((json) => UserShortModel.hasRole(json, 'manager'))
          .map(UserShortModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<ProjectShort>> getProjectShorts() async {
    try {
      final response = await _client.get(
        ApiConstants.projectShorts,
        queryParameters: {'page_size': 200},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => ProjectShortModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<ProjectMember>> getProjectMembers(int projectId) async {
    try {
      final response = await _client.get(ApiConstants.projectById(projectId));
      return ProjectMemberModel.membersFromProjectJson(
        ResponseMapper.asMap(response.data),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// Yaratish/yangilash uchun umumiy tana. Ixtiyoriy maydonlar faqat qiymati
  /// bo'lsa yuboriladi (PATCH'da yuborilmagani = o'zgarmagan). `priority`/
  /// `type` — API stringlari; `deadline` — ISO-8601. Taxminiy vaqt schema
  /// bo'yicha `estimated_input_hours`/`estimated_input_minutes` orqali yoziladi
  /// (`estimated_minutes` readOnly).
  Map<String, dynamic> _taskBody(NewTask task) {
    if (task.deadlineOnly) {
      return {'deadline': task.deadline.toIso8601String()};
    }
    return {
      if (task.project != null) 'project': task.project,
      'title': task.title,
      'description': task.description,
      'deadline': task.deadline.toIso8601String(),
      if (task.priority != null) 'priority': task.priority,
      if (task.type != null) 'type': task.type,
      if (task.assignee != null) 'assignee': task.assignee,
      if (task.position != null) 'position': task.position,
      if (task.taskPrice != null) 'task_price': task.taskPrice,
      if (task.penaltyPercentage != null)
        'penalty_percentage': task.penaltyPercentage,
      if (task.sprint != null) 'sprint': task.sprint,
      if (task.estimatedMinutes != null) ...{
        'estimated_input_hours': task.estimatedMinutes! ~/ 60,
        'estimated_input_minutes': task.estimatedMinutes! % 60,
      },
    };
  }

  @override
  Future<int> createTask(NewTask task) async {
    try {
      final response = await _client.post(
        ApiConstants.tasks,
        data: _taskBody(task),
      );
      return (ResponseMapper.asMap(response.data)['id'] as num?)?.toInt() ?? 0;
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> updateTask(int id, NewTask task) async {
    try {
      await _client.patch(ApiConstants.taskById(id), data: _taskBody(task));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<TaskDetail> getTaskDetail(int id) async {
    try {
      final response = await _client.get(ApiConstants.taskById(id));
      return TaskDetailModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<TaskAttachmentInfo>> getTaskAttachments(int taskId) async {
    try {
      final response = await _client.get(
        ApiConstants.taskAttachments,
        queryParameters: {'task': taskId},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map(
            (e) => TaskAttachmentInfoModel.fromJson(e.cast<String, dynamic>()),
          )
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> deleteAttachment(int id) async {
    try {
      await _client.delete(ApiConstants.taskAttachmentById(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> changeTaskStatus(int id, String status, {String? reason}) async {
    try {
      await _client.patch(
        ApiConstants.taskChangeStatus(id),
        data: {
          'status': status,
          if (reason != null && reason.isNotEmpty) 'rejection_reason': reason,
        },
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> uploadRejectionFile(int taskId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'task': taskId,
        'file': await MultipartFile.fromFile(filePath),
      });
      await _client.post(ApiConstants.taskRejectionFiles, data: formData);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> uploadAttachment(int taskId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'task': taskId,
        'file': await MultipartFile.fromFile(filePath),
      });
      await _client.post(ApiConstants.taskAttachments, data: formData);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    try {
      await _client.delete(ApiConstants.taskById(id));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
