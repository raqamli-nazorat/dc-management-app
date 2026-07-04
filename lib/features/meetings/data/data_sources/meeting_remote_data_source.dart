import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/meeting_attendance_model.dart';
import '../models/meeting_model.dart';

/// Yig‘ilishlar + qatnashuv backend bilan to‘g‘ridan-to‘g‘ri muloqot.
abstract interface class MeetingRemoteDataSource {
  Future<List<MeetingModel>> getMeetings();
  Future<MeetingModel> getMeeting(int id);

  /// Yig‘ilishdagi qatnashuv yozuvlari (`GET /meeting-attendance/?meeting=`).
  Future<List<MeetingAttendanceModel>> getMeetingAttendance(int meetingId);

  /// Qatnashmaslik sababini yuboradi
  /// (`PATCH /meeting-attendance/{attendanceId}/` → `{absence_reason}`).
  Future<MeetingAttendanceModel> submitAbsenceReason(
    int attendanceId,
    String reason,
  );
}

class MeetingRemoteDataSourceImpl implements MeetingRemoteDataSource {
  const MeetingRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<List<MeetingModel>> getMeetings() async {
    try {
      final response = await _client.get(ApiConstants.meetings);
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => MeetingModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingModel> getMeeting(int id) async {
    try {
      final response = await _client.get(ApiConstants.meetingById(id));
      return MeetingModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<List<MeetingAttendanceModel>> getMeetingAttendance(
    int meetingId,
  ) async {
    try {
      final response = await _client.get(
        ApiConstants.meetingAttendance,
        queryParameters: {'meeting': meetingId},
      );
      return ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => MeetingAttendanceModel.fromJson(e.cast<String, dynamic>()))
          .toList();
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<MeetingAttendanceModel> submitAbsenceReason(
    int attendanceId,
    String reason,
  ) async {
    try {
      final response = await _client.patch(
        ApiConstants.meetingAttendanceById(attendanceId),
        data: {'absence_reason': reason},
      );
      return MeetingAttendanceModel.fromJson(
        ResponseMapper.asMap(response.data),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
