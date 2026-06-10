import '../../domain/entities/auth_user.dart';

/// `data.user` JSON modeli. Entityga / JSONga o‘giradi (cache uchun).
class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.username,
    this.avatar,
    this.phoneNumber,
    this.region,
    this.district,
    this.position,
    this.roles = const <String>[],
    this.activeRole,
    this.dateJoined,
  });

  final int id;
  final String username;
  final String? avatar;
  final String? phoneNumber;
  final String? region;
  final String? district;
  final String? position;
  final List<String> roles;
  final String? activeRole;
  final String? dateJoined;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      phoneNumber: json['phone_number'] as String?,
      region: json['region'] as String?,
      district: json['district'] as String?,
      position: json['position'] as String?,
      roles:
          (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const <String>[],
      activeRole: json['active_role'] as String?,
      dateJoined: json['date_joined'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'avatar': avatar,
        'phone_number': phoneNumber,
        'region': region,
        'district': district,
        'position': position,
        'roles': roles,
        'active_role': activeRole,
        'date_joined': dateJoined,
      };

  AuthUser toEntity() => AuthUser(
        id: id,
        username: username,
        avatar: avatar,
        phoneNumber: phoneNumber,
        region: region,
        district: district,
        position: position,
        roles: roles,
        activeRole: activeRole,
        dateJoined: dateJoined == null ? null : DateTime.tryParse(dateJoined!),
      );
}
