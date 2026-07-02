import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/response_mapper.dart';
import '../models/profile_model.dart';

/// Profil backend bilan to‘g‘ridan-to‘g‘ri muloqot (`/users/me/`).
abstract interface class ProfileRemoteDataSource {
  Future<ProfileModel> getMe();
  Future<ProfileModel> updateMe(Map<String, dynamic> fields);
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
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
  Future<ProfileModel> updateMe(Map<String, dynamic> fields) async {
    try {
      final response = await _client.patch(ApiConstants.usersMe, data: fields);
      return ProfileModel.fromJson(ResponseMapper.asMap(response.data));
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _client.put(
        ApiConstants.usersMeChangePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw ResponseMapper.mapDioException(e);
    }
  }
}
