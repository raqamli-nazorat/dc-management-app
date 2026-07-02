import '../../domain/entities/statistics.dart';

int _int(dynamic v) => (v as num?)?.toInt() ?? 0;
double _double(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

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
    Map<String, dynamic> section(String key) =>
        (json[key] as Map?)?.cast<String, dynamic>() ?? const {};
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

/// [EfficiencyStatistics] JSON serializatsiyasi (`/users/me/efficiency/`).
class EfficiencyStatisticsModel extends EfficiencyStatistics {
  const EfficiencyStatisticsModel({
    required super.overallEfficiency,
    required super.taskScore,
    required super.meetingScore,
    required super.metrics,
    required super.insights,
  });

  factory EfficiencyStatisticsModel.fromJson(Map<String, dynamic> json) {
    final m = (json['metrics'] as Map?)?.cast<String, dynamic>() ?? const {};
    return EfficiencyStatisticsModel(
      overallEfficiency: _double(json['overall_efficiency']),
      taskScore: _double(json['task_score']),
      meetingScore: _double(json['meeting_score']),
      metrics: EfficiencyMetrics(
        totalTasks: _int(m['total_tasks']),
        overdueTasks: _int(m['overdue_tasks']),
        rejectedTasks: _int(m['rejected_tasks']),
        totalReopenedActions: _int(m['total_reopened_actions']),
        totalMeetings: _int(m['total_meetings']),
        unexcusedMeetings: _int(m['unexcused_meetings']),
      ),
      insights: (json['insights'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }
}
