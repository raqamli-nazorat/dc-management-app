import 'coordinate.dart';

class Routes implements Coordinate {
  const Routes._({
    required this.name,
    required this.path,
  });

  @override
  final String name;
  @override
  final String path;

  /// Auth
  static const authIntro = Routes._(name: 'auth_intro_page', path: '/auth_intro');
  static const splash = Routes._(name: 'splash', path: '/splash');
  static const login = Routes._(name: 'login', path: '/login');
  static const checkCode = Routes._(name: 'check_code_page', path: '/check_code');
  static const confirmCode = Routes._(name: "confirm_code", path: "/confirm_code");
  static const pinCode = Routes._(name: "pin_code", path: "/pin_code");
  static const roleSelect = Routes._(name: "role_select", path: "/role_select");

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  /// Bildirishnomalar (home ustidan push qilinadi).
  static const notifications =
      Routes._(name: 'notifications', path: '/notifications');

  /// Profil (home ustidan, AppBar user ma’lumotlari bosilganda push qilinadi).
  static const profile = Routes._(name: 'profile', path: '/profile');

  /// Xavfsizlik (profil sozlamalaridan push qilinadi).
  static const security = Routes._(name: 'security', path: '/security');

  /// Vazifalar ro‘yxati.
  static const tasks = Routes._(name: 'tasks', path: '/tasks');

  /// Yig‘ilishlar ro‘yxati.
  static const meetings = Routes._(name: 'meetings', path: '/meetings');

  /// "Yig‘ilishga qatnashmadingiz" — sabab yozish (meeting id path param).
  static const meetingReason =
      Routes._(name: 'meeting_reason', path: '/meetings/:id/reason');

  @override
  String toString() => 'name=$name, path=$path';
}
