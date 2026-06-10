import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_session_model.dart';

/// Auth backend bilan to‘g‘ridan-to‘g‘ri muloqot.
///
/// Javob konverti: `{ data, error: { errorId, isFriendly, errorMsg }, success }`.
/// HTTP/biznes xatolari tegishli `Exception`larga aylantiriladi:
/// 401 → [UnauthorizedException], 429 → [ThrottleException],
/// ulanish → [NetworkException], qolgani → [ServerException].
abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String username,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<AuthSessionModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        ApiConstants.login,
        data: {'username': username, 'password': password},
      );

      final body = (response.data as Map?)?.cast<String, dynamic>() ?? {};
      final data = body['data'];
      if (body['success'] == true && data is Map) {
        return AuthSessionModel.fromJson(data.cast<String, dynamic>());
      }
      // 2xx, lekin success=false (kamdan-kam) — konvertdan xatoni o‘qiymiz.
      throw ServerException(_messageFromBody(body));
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  /// Konvertdagi `error.errorMsg`ni ajratib oladi.
  String _messageFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['errorMsg'] is String) {
      return error['errorMsg'] as String;
    }
    return 'Server xatosi';
  }

  Exception _mapDioException(DioException e) {
    // Ulanish/timeout xatolari.
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException();
      default:
        break;
    }

    final status = e.response?.statusCode;
    final body = (e.response?.data as Map?)?.cast<String, dynamic>();
    final message = body == null ? null : _messageFromBody(body);

    if (status == 401) {
      return UnauthorizedException(message ?? 'Unauthorized');
    }
    if (status == 429) {
      return ThrottleException(message ?? 'Too many requests');
    }
    return ServerException(message ?? 'Server xatosi');
  }
}
