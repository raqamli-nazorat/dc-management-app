import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/new_user.dart';
import '../../domain/entities/users_filter.dart';
import '../models/app_user_model.dart';

/// Foydalanuvchilar backend bilan to'g'ridan-to'g'ri muloqot.
abstract interface class UsersRemoteDataSource {
  /// Bitta sahifa (`GET /users/?page=` + filtr paramlari).
  Future<AppUserPage> getUsers({int page, UsersFilter filter});

  /// Bitta foydalanuvchi (`GET /users/{id}/`).
  Future<AppUser> getUser(int id);

  /// Yangi foydalanuvchi (`POST /users/`, multipart).
  Future<AppUser> createUser(NewUser user);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  const UsersRemoteDataSourceImpl(this._client);

  static const _pageSize = 20;

  final DioClient _client;

  @override
  Future<AppUserPage> getUsers({
    int page = 1,
    UsersFilter filter = UsersFilter.empty,
  }) async {
    try {
      final response = await _client.get(
        ApiConstants.users,
        queryParameters: {
          'page': page,
          'page_size': _pageSize,
          ..._filterParams(filter),
        },
      );
      final body = ResponseMapper.asMap(response.data);
      final items = ResponseMapper.asList(response.data)
          .whereType<Map>()
          .map((e) => AppUserModel.fromJson(e.cast<String, dynamic>()))
          .toList();
      return (items: items, hasMore: body['next'] != null);
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<AppUser> getUser(int id) async {
    try {
      final response = await _client.get(ApiConstants.userById(id));
      return AppUserModel.fromJson(
        ResponseMapper.asMap(response.data).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<AppUser> createUser(NewUser user) async {
    try {
      final form = FormData.fromMap({
        'username': user.username,
        'password': user.password,
        'confirm_password': user.confirmPassword,
        'phone_number': user.phoneNumber,
        'region': user.regionId,
        'district': user.districtId,
        'position': user.positionId,
        'roles': user.roles,
        if (user.cardNumber.isNotEmpty) 'card_number': user.cardNumber,
        if (user.fixedSalary.isNotEmpty) 'fixed_salary': user.fixedSalary,
        if (user.passportSeries.isNotEmpty)
          'passport_series': user.passportSeries,
        if (user.socialLinks.isNotEmpty)
          'social_links': jsonEncode(user.socialLinks),
        if (user.avatarPath != null)
          'avatar': await MultipartFile.fromFile(user.avatarPath!),
        if (user.passportImagePath != null)
          'passport_image': await MultipartFile.fromFile(
            user.passportImagePath!,
          ),
      });
      final response = await _client.post(ApiConstants.users, data: form);
      return AppUserModel.fromJson(
        ResponseMapper.asMap(response.data).cast<String, dynamic>(),
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  /// [UsersFilter] → `GET /users/` query paramlari (faqat to'ldirilganlari).
  Map<String, dynamic> _filterParams(UsersFilter f) => {
    if (f.search.trim().isNotEmpty) 'search': f.search.trim(),
    if (f.positionId != null) 'position': '${f.positionId}',
    if (f.role != null) 'roles': f.role,
    if (f.ordering != null) 'ordering': f.ordering!.apiValue,
  };
}
