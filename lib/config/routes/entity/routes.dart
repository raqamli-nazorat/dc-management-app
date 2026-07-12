import 'coordinate.dart';

class Routes implements Coordinate {
  const Routes._({required this.name, required this.path});

  @override
  final String name;
  @override
  final String path;

  /// Auth
  static const authIntro = Routes._(
    name: 'auth_intro_page',
    path: '/auth_intro',
  );
  static const splash = Routes._(name: 'splash', path: '/splash');
  static const login = Routes._(name: 'login', path: '/login');
  static const checkCode = Routes._(
    name: 'check_code_page',
    path: '/check_code',
  );
  static const confirmCode = Routes._(
    name: "confirm_code",
    path: "/confirm_code",
  );
  static const pinCode = Routes._(name: "pin_code", path: "/pin_code");
  static const roleSelect = Routes._(name: "role_select", path: "/role_select");

  static const root = Routes._(name: 'root', path: '/');
  static const home = Routes._(name: 'home_page', path: '/home_page');

  /// Bildirishnomalar (home ustidan push qilinadi).
  static const notifications = Routes._(
    name: 'notifications',
    path: '/notifications',
  );

  /// Profil (home ustidan, AppBar user ma’lumotlari bosilganda push qilinadi).
  static const profile = Routes._(name: 'profile', path: '/profile');

  /// Xavfsizlik (profil sozlamalaridan push qilinadi).
  static const security = Routes._(name: 'security', path: '/security');

  /// Vazifalar ro‘yxati.
  static const tasks = Routes._(name: 'tasks', path: '/tasks');

  /// Loyihalar ro‘yxati.
  static const projectsList = Routes._(
    name: 'projects_list',
    path: '/projects',
  );

  /// Loyiha qo‘shish formasi.
  static const projectCreate = Routes._(
    name: 'project_create',
    path: '/projects/create',
  );

  static const projectDetails = Routes._(
    name: 'project_details',
    path: '/projects/:id/details',
  );

  static const projectEdit = Routes._(
    name: 'project_edit',
    path: '/projects/:id/edit',
  );

  /// Loyihalarni filtrlash sahifasi.
  static const projectFilter = Routes._(
    name: 'project_filter',
    path: '/projects/filter',
  );

  /// Vazifa qo‘shish formasi (vazifalar ro‘yxatidan push qilinadi).
  static const taskCreate = Routes._(
    name: 'task_create',
    path: '/tasks/create',
  );

  /// Vazifalarni filtrlash sahifasi (vazifalar ro‘yxatidan push qilinadi).
  static const taskFilter = Routes._(
    name: 'task_filter',
    path: '/tasks/filter',
  );

  /// Filtr uchun ko‘p-tanlov sahifasi (Loyiha / Muallif / Xodim tanlash).
  static const taskMultiSelect = Routes._(
    name: 'task_multi_select',
    path: '/tasks/filter/select',
  );

  /// Yig‘ilishlar ro‘yxati.
  static const meetings = Routes._(name: 'meetings', path: '/meetings');

  static const meetingCreate = Routes._(
    name: 'meeting_create',
    path: '/meetings/create',
  );
  static const meetingFilter = Routes._(
    name: 'meeting_filter',
    path: '/meetings/filter',
  );

  /// "Yig‘ilishga qatnashmadingiz" — sabab yozish (meeting id path param).
  static const meetingReason = Routes._(
    name: 'meeting_reason',
    path: '/meetings/:id/reason',
  );

  @override
  String toString() => 'name=$name, path=$path';
}
