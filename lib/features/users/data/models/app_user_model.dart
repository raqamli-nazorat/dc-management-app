import '../../domain/entities/app_user.dart';

/// `GET /users/` `User` sxemasi → [AppUser]. Bardoshli parsing:
/// `position_info`/`region_info`/`district_info` obyekt yoki yo'q bo'lishi,
/// decimal maydonlar string yoki son kelishi mumkin.
abstract final class AppUserModel {
  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      positionName: _infoName(json['position_info']),
      roles: [for (final role in json['roles'] as List? ?? const []) '$role'],
      fixedSalary: _decimal(json['fixed_salary']),
      balance: _decimal(json['balance']),
      phoneNumber: json['phone_number'] as String? ?? '',
      cardNumber: _decimal(json['card_number']),
      regionName: _infoName(json['region_info']),
      districtName: _infoName(json['district_info']),
      passportSeries: json['passport_series'] as String? ?? '',
      passportImage: json['passport_image'] as String? ?? '',
      dateJoined: DateTime.tryParse(json['date_joined'] as String? ?? ''),
    );
  }

  /// `{id, name}` obyekt, tayyor string yoki null.
  static String _infoName(Object? value) => value is Map
      ? '${value['name'] ?? ''}'
      : value is String
      ? value
      : '';

  static String _decimal(Object? value) => value == null ? '' : '$value';
}
