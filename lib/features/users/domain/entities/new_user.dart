import 'package:equatable/equatable.dart';

/// `POST /users/` uchun kiritiladigan foydalanuvchi ma'lumotlari.
class NewUser extends Equatable {
  const NewUser({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.regionId,
    required this.districtId,
    required this.positionId,
    required this.roles,
    required this.phoneNumber,
    this.cardNumber = '',
    this.fixedSalary = '',
    this.passportSeries = '',
    this.socialLinks = const [],
    this.avatarPath,
    this.passportImagePath,
  });

  final String username;
  final String password;
  final String confirmPassword;
  final int regionId;
  final int districtId;
  final int positionId;
  final List<String> roles;
  final String phoneNumber;
  final String cardNumber;
  final String fixedSalary;
  final String passportSeries;
  final List<String> socialLinks;
  final String? avatarPath;
  final String? passportImagePath;

  @override
  List<Object?> get props => [
    username,
    password,
    confirmPassword,
    regionId,
    districtId,
    positionId,
    roles,
    phoneNumber,
    cardNumber,
    fixedSalary,
    passportSeries,
    socialLinks,
    avatarPath,
    passportImagePath,
  ];
}
