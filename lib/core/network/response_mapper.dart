import 'package:dio/dio.dart';

import '../error/exceptions.dart';

/// Backend javob konvertini ochuvchi va Dio xatolarini tipli `Exception`larga
/// aylantiruvchi umumiy yordamchilar.
///
/// Konvert: `{ data, error: { errorId, errorMsg }, success }`. Ba’zi endpointlar
/// konvertsiz (to‘g‘ridan-to‘g‘ri model) qaytarishi mumkin — shu bois bardoshli:
/// `success`/`data` bo‘lsa ichini, aks holda tananing o‘zini qaytaradi.
abstract final class ResponseMapper {
  /// Konvert ichidagi `data`ni (yoki tananing o‘zini) `Map` sifatida qaytaradi.
  static Map<String, dynamic> asMap(dynamic responseData) {
    final body = (responseData as Map?)?.cast<String, dynamic>() ?? {};
    final data = body['data'];
    if (data is Map) return data.cast<String, dynamic>();
    return body;
  }

  /// Konvert ichidagi `data`ni (yoki tananing o‘zini) `List` sifatida qaytaradi.
  /// Sahifalangan javoblarda (`{results: [...]}`) `results` ham tekshiriladi.
  static List<dynamic> asList(dynamic responseData) {
    if (responseData is List) return responseData;
    final body = (responseData as Map?)?.cast<String, dynamic>() ?? {};
    final data = body['data'];
    if (data is List) return data;
    if (data is Map && data['results'] is List) return data['results'] as List;
    if (body['results'] is List) return body['results'] as List;
    return const [];
  }

  static String messageFromBody(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map && error['errorMsg'] is String) {
      return error['errorMsg'] as String;
    }
    if (body['detail'] is String) return body['detail'] as String;
    return 'Server xatosi';
  }

  static Exception mapDioException(DioException e) {
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
    final message = body == null ? null : messageFromBody(body);

    if (status == 401) return UnauthorizedException(message ?? 'Unauthorized');
    if (status == 429) return ThrottleException(message ?? 'Too many requests');
    return ServerException(message ?? 'Server xatosi');
  }
}
