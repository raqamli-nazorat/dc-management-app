part of 'task_reports_bloc.dart';

sealed class TaskReportsEvent extends Equatable {
  const TaskReportsEvent();
  @override
  List<Object?> get props => [];
}

class TaskReportsRequested extends TaskReportsEvent {
  const TaskReportsRequested();
}

class TaskReportsLoadMore extends TaskReportsEvent {
  const TaskReportsLoadMore();
}

class TaskReportsSearchChanged extends TaskReportsEvent {
  const TaskReportsSearchChanged(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class TaskReportsFilterChanged extends TaskReportsEvent {
  const TaskReportsFilterChanged(this.filter);
  final TaskReportFilter filter;
  @override
  List<Object?> get props => [filter];
}
