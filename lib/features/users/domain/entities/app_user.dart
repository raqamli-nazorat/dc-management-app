import 'package:equatable/equatable.dart';

/// Foydalanuvchi (`GET /users/` — `User` sxemasi, admin ro'yxati).
///
/// Karta faqat shu maydonlarni ko'rsatadi; sxemadagi qolgan maydonlar
/// (passport, region va h.k.) hozircha UIda ishlatilmaydi.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.username,
    required this.avatar,
    required this.positionName,
    required this.roles,
    required this.fixedSalary,
    required this.balance,
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

  @override
  List<Object?> get props => [
    id,
    username,
    avatar,
    positionName,
    roles,
    fixedSalary,
    balance,
  ];
}

/// Bitta sahifa natijasi (`{count, next, results}`).
typedef AppUserPage = ({List<AppUser> items, bool hasMore});
