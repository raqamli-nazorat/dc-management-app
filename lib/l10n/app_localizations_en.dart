// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get pinTitle => 'Enter PIN code';

  @override
  String get pinSubtitle => 'Enter your PIN code to confirm sign-in';

  @override
  String get pinIncorrect => 'Incorrect PIN code';

  @override
  String get pinRetry => 'Please try again';

  @override
  String get pinBlocked => 'Access temporarily blocked';

  @override
  String pinBlockedRetryIn(String time) {
    return 'Try again in: $time';
  }

  @override
  String get roleTitle => 'You can use the app with multiple roles';

  @override
  String get roleSubtitle => 'Select one of the following.';

  @override
  String get roleAdministrator => 'Administrator';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleSupervisor => 'Supervisor';

  @override
  String get roleEmployee => 'Employee';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationMarkAllRead => 'Mark all as read';

  @override
  String get notificationClose => 'Close';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get commonRetry => 'Retry';

  @override
  String get navHome => 'Home';

  @override
  String get navUsers => 'Users';

  @override
  String get navProjects => 'Projects';

  @override
  String get navFinance => 'Finance';

  @override
  String get navReports => 'Reports';

  @override
  String get statPeriodSelect => 'Select period';

  @override
  String get statPeriod1Month => '1 month';

  @override
  String get statPeriod3Months => '3 months';

  @override
  String get statPeriod6Months => '6 months';

  @override
  String get statPeriod1Year => '1 year';

  @override
  String get statTasksTitle => 'Tasks';

  @override
  String get statTaskTodo => 'To do';

  @override
  String get statTaskInProgress => 'In progress';

  @override
  String get statTaskDone => 'Done';

  @override
  String get statTaskProduction => 'In production';

  @override
  String get statTaskChecked => 'Checked';

  @override
  String get statTaskRejected => 'Rejected';

  @override
  String get statTaskOverdue => 'Overdue';

  @override
  String get statProjectsTitle => 'Projects';

  @override
  String get statProjectCompleted => 'Completed';

  @override
  String get statProjectActive => 'Active';

  @override
  String get statProjectCancelled => 'Cancelled';

  @override
  String get statProjectOverdue => 'Overdue';

  @override
  String get statProjectPlanning => 'Planning';

  @override
  String get statMeetingsTitle => 'Meetings dynamics';

  @override
  String get statMeetingAttended => 'Attended';

  @override
  String get statMeetingExcused => 'Excused';

  @override
  String get statMeetingUnexcused => 'Unexcused';

  @override
  String get statEmpty => 'No data';

  @override
  String profileTitle(String role) {
    return '$role information';
  }

  @override
  String get profileRoleManage => 'Manage role';

  @override
  String get profileSecurity => 'Security';

  @override
  String get profileTheme => 'Design theme';

  @override
  String get profileAbout => 'About app';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String roleSwitchedTitle(String role) {
    return 'Switched to $role.';
  }

  @override
  String roleSwitchedSubtitle(String role) {
    return 'You are now working as $role.';
  }

  @override
  String get commonError => 'Something went wrong. Please try again later.';

  @override
  String get networkError => 'No internet connection. Check your connection.';
}
