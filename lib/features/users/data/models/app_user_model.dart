import '../../domain/entities/app_user.dart';

/// `GET /users/` `User` sxemasi → [AppUser]. Bardoshli parsing:
/// `position_info` obyekt yoki yo'q bo'lishi, decimal maydonlar string yoki
/// son kelishi mumkin.
abstract final class AppUserModel {
  static AppUser fromJson(Map<String, dynamic> json) {
    final position = json['position_info'];
    return AppUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String? ?? '',
      positionName: position is Map
          ? '${position['name'] ?? ''}'
          : position is String
          ? position
          : '',
      roles: [
        for (final role in json['roles'] as List? ?? const []) '$role',
      ],
      fixedSalary: _decimal(json['fixed_salary']),
      balance: _decimal(json['balance']),
    );
  }

  static String _decimal(Object? value) => value == null ? '' : '$value';
}
