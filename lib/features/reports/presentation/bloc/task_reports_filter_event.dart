part of 'task_reports_filter_bloc.dart';

sealed class TaskReportsFilterEvent extends Equatable {
  const TaskReportsFilterEvent();
  @override
  List<Object?> get props => [];
}

class TaskReportsFilterOptionsRequested extends TaskReportsFilterEvent {
  const TaskReportsFilterOptionsRequested();
}
