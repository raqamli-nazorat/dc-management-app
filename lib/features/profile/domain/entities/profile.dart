import 'package:equatable/equatable.dart';

/// Joriy foydalanuvchi profili (`/users/me/`).
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.avatar,
    required this.username,
    required this.phoneNumber,
    required this.cardNumber,
    required this.passportSeries,
    required this.passportImage,
    required this.region,
    required this.district,
    required this.position,
    required this.roles,
    required this.activeRole,
    required this.fixedSalary,
    required this.balance,
    required this.socialLinks,
    required this.dateJoined,
  });

  final int id;
  final String avatar;
  final String username;
  final String phoneNumber;
  final String cardNumber;
  final String passportSeries;
  final String passportImage;
  final String region;
  final String district;
  final String position;
  final List<String> roles;
  final String activeRole;
  final String fixedSalary;
  final String balance;
  final String socialLinks;
  final DateTime? dateJoined;

  /// Header uchun ko‘rsatiladigan ism — hozircha `username`.
  String get displayName => username;

  /// Header ost-yozuvi — lavozim bo‘lsa u, aks holda faol rol.
  String get displaySubtitle => position.isNotEmpty ? position : activeRole;

  @override
  List<Object?> get props => [
        id,
        avatar,
        username,
        phoneNumber,
        cardNumber,
        passportSeries,
        passportImage,
        region,
        district,
        position,
        roles,
        activeRole,
        fixedSalary,
        balance,
        socialLinks,
        dateJoined,
      ];
}
