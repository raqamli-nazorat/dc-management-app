import 'dart:convert';

import '../../domain/entities/profile.dart';

/// [Profile] entity’sining JSON serializatsiyasi (`/users/me/`).
///
/// Backend maydonlari snake_case. Parsing bardoshli: yetishmagan/null
/// maydonlar bo‘sh qiymatga tushadi (UI hech qachon null’ga urилmaydi).
class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.avatar,
    required super.username,
    required super.phoneNumber,
    required super.cardNumber,
    required super.passportSeries,
    required super.passportImage,
    required super.region,
    required super.district,
    required super.position,
    required super.roles,
    required super.activeRole,
    required super.fixedSalary,
    required super.balance,
    required super.socialLinks,
    required super.dateJoined,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    String str(String key) => json[key]?.toString() ?? '';
    return ProfileModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      avatar: str('avatar'),
      username: str('username'),
      phoneNumber: str('phone_number'),
      cardNumber: str('card_number'),
      passportSeries: str('passport_series'),
      passportImage: str('passport_image'),
      region: str('region'),
      district: str('district'),
      position: str('position'),
      roles:
          (json['roles'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      activeRole: str('active_role'),
      fixedSalary: str('fixed_salary'),
      balance: str('balance'),
      socialLinks: _socialLinks(json['social_links']),
      dateJoined: DateTime.tryParse(str('date_joined')),
    );
  }

  // OpenAPI `social_links` uchun aniq tur bermaydi; Figma ikki alohida
  // havolani ko'rsatadi. Backenddan list yoki JSON-string kelishini qabul qilamiz.
  static List<String> _socialLinks(Object? value) {
    if (value is List) {
      return value.map((link) => link.toString()).toList();
    }
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((link) => link.toString()).toList();
        }
      } on FormatException {
        // Eski yoki kutilmagan string qiymat ham bitta havola sifatida qoladi.
      }
      return [value];
    }
    return const [];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'avatar': avatar,
    'username': username,
    'phone_number': phoneNumber,
    'card_number': cardNumber,
    'passport_series': passportSeries,
    'passport_image': passportImage,
    'region': region,
    'district': district,
    'position': position,
    'roles': roles,
    'active_role': activeRole,
    'fixed_salary': fixedSalary,
    'balance': balance,
    'social_links': socialLinks,
    'date_joined': dateJoined?.toIso8601String(),
  };
}
