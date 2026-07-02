import 'package:equatable/equatable.dart';

/// Bosh sahifa grafiklari uchun davr statistikasi (`/users/me/period-statistics/`).
class PeriodStatistics extends Equatable {
  const PeriodStatistics({
    required this.projects,
    required this.tasks,
    required this.meetings,
  });

  final ProjectStats projects;
  final TaskStats tasks;
  final MeetingStats meetings;

  @override
  List<Object?> get props => [projects, tasks, meetings];
}

/// Loyihalar grafigi (bar chart) uchun ko‘rsatkichlar.
class ProjectStats extends Equatable {
  const ProjectStats({
    required this.total,
    required this.planning,
    required this.active,
    required this.overdue,
    required this.completed,
    required this.cancelled,
    required this.currentWork,
    required this.completionRate,
  });

  final int total;
  final int planning;
  final int active;
  final int overdue;
  final int completed;
  final int cancelled;
  final int currentWork;
  final double completionRate;

  @override
  List<Object?> get props => [
        total,
        planning,
        active,
        overdue,
        completed,
        cancelled,
        currentWork,
        completionRate,
      ];
}

/// Vazifalar grafigi (line chart) uchun ko‘rsatkichlar.
class TaskStats extends Equatable {
  const TaskStats({
    required this.total,
    required this.todo,
    required this.inProgress,
    required this.overdue,
    required this.done,
    required this.checked,
    required this.production,
    required this.rejectedTasks,
    required this.totalRejections,
    required this.overallCompleted,
    required this.completionRate,
  });

  final int total;
  final int todo;
  final int inProgress;
  final int overdue;
  final int done;
  final int checked;
  final int production;
  final int rejectedTasks;
  final int totalRejections;
  final int overallCompleted;
  final double completionRate;

  @override
  List<Object?> get props => [
        total,
        todo,
        inProgress,
        overdue,
        done,
        checked,
        production,
        rejectedTasks,
        totalRejections,
        overallCompleted,
        completionRate,
      ];
}

/// Yig‘ilishlar dinamikasi grafigi (donut chart) uchun ko‘rsatkichlar.
class MeetingStats extends Equatable {
  const MeetingStats({
    required this.total,
    required this.attended,
    required this.missed,
    required this.withReason,
    required this.unexcused,
    required this.totalDurationMinutes,
    required this.uniqueParticipants,
    required this.uniqueMeetings,
    required this.attendanceRate,
  });

  final int total;
  final int attended;
  final int missed;
  final int withReason;
  final int unexcused;
  final int totalDurationMinutes;
  final int uniqueParticipants;
  final int uniqueMeetings;
  final double attendanceRate;

  @override
  List<Object?> get props => [
        total,
        attended,
        missed,
        withReason,
        unexcused,
        totalDurationMinutes,
        uniqueParticipants,
        uniqueMeetings,
        attendanceRate,
      ];
}

/// Samaradorlik ko‘rsatkichlari (`/users/me/efficiency/`).
class EfficiencyStatistics extends Equatable {
  const EfficiencyStatistics({
    required this.overallEfficiency,
    required this.taskScore,
    required this.meetingScore,
    required this.metrics,
    required this.insights,
  });

  final double overallEfficiency;
  final double taskScore;
  final double meetingScore;
  final EfficiencyMetrics metrics;
  final List<String> insights;

  @override
  List<Object?> get props => [
        overallEfficiency,
        taskScore,
        meetingScore,
        metrics,
        insights,
      ];
}

class EfficiencyMetrics extends Equatable {
  const EfficiencyMetrics({
    required this.totalTasks,
    required this.overdueTasks,
    required this.rejectedTasks,
    required this.totalReopenedActions,
    required this.totalMeetings,
    required this.unexcusedMeetings,
  });

  final int totalTasks;
  final int overdueTasks;
  final int rejectedTasks;
  final int totalReopenedActions;
  final int totalMeetings;
  final int unexcusedMeetings;

  @override
  List<Object?> get props => [
        totalTasks,
        overdueTasks,
        rejectedTasks,
        totalReopenedActions,
        totalMeetings,
        unexcusedMeetings,
      ];
}
