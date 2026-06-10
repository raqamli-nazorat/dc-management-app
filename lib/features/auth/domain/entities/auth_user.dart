import 'package:equatable/equatable.dart';

/// Tizimga kirgan foydalanuvchi (domen entity — toza Dart).
class AuthUser extends Equatable {
  const AuthUser({
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
  final DateTime? dateJoined;

  @override
  List<Object?> get props => [
        id,
        username,
        avatar,
        phoneNumber,
        region,
        district,
        position,
        roles,
        activeRole,
        dateJoined,
      ];
}
