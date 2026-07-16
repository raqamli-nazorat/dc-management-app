import '../../domain/entities/statistics.dart';

/// Backend son maydonlarni ba’zan matn (`"12"`, `"85.5"`) yoki `null` qilib
/// qaytaradi — `as num?` bunda TypeError otardi, shu bois bardoshli parsing.
double _double(dynamic v) => switch (v) {
      num() => v.toDouble(),
      String() => double.tryParse(v) ?? 0.0,
      _ => 0.0,
    };
int _int(dynamic v) => _double(v).toInt();

/// [PeriodStatistics] JSON serializatsiyasi (`/users/me/period-statistics/`).
///
/// Parsing bardoshli — yetishmagan bo‘limlar/maydonlar 0 ga tushadi.
class PeriodStatisticsModel extends PeriodStatistics {
  const PeriodStatisticsModel({
    required super.projects,
    required super.tasks,
    required super.meetings,
  });

  factory PeriodStatisticsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> section(String key) {
      final v = json[key];
      return v is Map ? v.cast<String, dynamic>() : const {};
    }
    return PeriodStatisticsModel(
      projects: _projects(section('projects')),
      tasks: _tasks(section('tasks')),
      meetings: _meetings(section('meetings')),
    );
  }

  static ProjectStats _projects(Map<String, dynamic> j) => ProjectStats(
        total: _int(j['total']),
        planning: _int(j['planning']),
        active: _int(j['active']),
        overdue: _int(j['overdue']),
        completed: _int(j['completed']),
        cancelled: _int(j['cancelled']),
        currentWork: _int(j['current_work']),
        completionRate: _double(j['completion_rate']),
      );

  static TaskStats _tasks(Map<String, dynamic> j) => TaskStats(
        total: _int(j['total']),
        todo: _int(j['todo']),
        inProgress: _int(j['in_progress']),
        overdue: _int(j['overdue']),
        done: _int(j['done']),
        checked: _int(j['checked']),
        production: _int(j['production']),
        rejectedTasks: _int(j['rejected_tasks']),
        totalRejections: _int(j['total_rejections']),
        overallCompleted: _int(j['overall_completed']),
        completionRate: _double(j['completion_rate']),
      );

  static MeetingStats _meetings(Map<String, dynamic> j) => MeetingStats(
        total: _int(j['total']),
        attended: _int(j['attended']),
        missed: _int(j['missed']),
        withReason: _int(j['with_reason']),
        unexcused: _int(j['unexcused']),
        totalDurationMinutes: _int(j['total_duration_minutes']),
        uniqueParticipants: _int(j['unique_participants']),
        uniqueMeetings: _int(j['unique_meetings']),
        attendanceRate: _double(j['attendance_rate']),
      );
}
