import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/profile_model.dart';
import '../../domain/entities/profile_update.dart';

/// Profil backend bilan to‘g‘ridan-to‘g‘ri muloqot (`/users/me/`).
abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getMe();
  Future<ProfileModel> updateMe(ProfileUpdate update);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<ProfileModel> getMe() async {
    try {
      final response = await _client.get(ApiConstants.usersMe);
      return ProfileModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<ProfileModel> updateMe(ProfileUpdate update) async {
    try {
      final data = update.avatarPath == null
          ? update.fields
          : FormData.fromMap({
              for (final entry in update.fields.entries)
                entry.key: entry.value is List
                    ? jsonEncode(entry.value)
                    : entry.value,
              'avatar': await MultipartFile.fromFile(update.avatarPath!),
            });
      final response = await _client.patch(ApiConstants.usersMe, data: data);
      return ProfileModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      await _client.put(
        ApiConstants.usersMeChangePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmNewPassword,
        },
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
