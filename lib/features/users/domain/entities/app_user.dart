import 'package:equatable/equatable.dart';

/// Foydalanuvchi (`GET /users/` va `GET /users/{id}/` — `User` sxemasi).
///
/// Ro'yxat kartasi va detail sahifa bir xil sxemadan oziqlanadi, shu sabab
/// entity bitta; sxemadagi qolgan maydonlar (social_links va h.k.) hozircha
/// UIda ishlatilmaydi.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.positionName,
    required this.roles,
    required this.fixedSalary,
    required this.balance,
    this.phoneNumber = '',
    this.cardNumber = '',
    this.regionName = '',
    this.districtName = '',
    this.passportSeries = '',
    this.passportImage = '',
    this.dateJoined,
  });

  final int id;

  /// F.I.O (`username`).
  final String username;

  final String avatar;

  /// Lavozim nomi (`position_info.name`).
  final String positionName;

  /// Xom rol kalitlari (`roles`) — UI [RolePresentation] bilan lokalizatsiya
  /// qiladi.
  final List<String> roles;

  /// API decimal string (`fixed_salary`), masalan `12000000.00`.
  final String fixedSalary;

  /// API decimal string (`balance`).
  final String balance;

  final String phoneNumber;
  final String cardNumber;

  /// `region_info.name`.
  final String regionName;

  /// `district_info.name`.
  final String districtName;

  /// `passport_series` — seriya+raqam bitta string (masalan `AA1425053`).
  final String passportSeries;

  /// `passport_image` — URI (bo'sh bo'lsa bo'lim ko'rsatilmaydi).
  final String passportImage;

  /// `date_joined` — sxemada yo'q, lekin backend qaytarsa ko'rsatiladi
  /// (Yaratilgan vaqt maydoni).
  final DateTime? dateJoined;

  @override
  List<Object?> get props => [
    id,
    username,
    avatar,
    positionName,
    roles,
    fixedSalary,
    balance,
    phoneNumber,
    cardNumber,
    regionName,
    districtName,
    passportSeries,
    passportImage,
    dateJoined,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef AppUserPage = ({List<AppUser> items, bool hasMore});
