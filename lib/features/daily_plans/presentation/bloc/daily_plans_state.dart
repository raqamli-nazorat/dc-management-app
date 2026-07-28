part of 'daily_plans_bloc.dart';

enum DailyPlansStatus { initial, loading, success, failure }

enum DailyPlansMessage { planSaved, planDeleted, failure }

class DailyPlansState extends Equatable {
  const DailyPlansState({
    this.status = DailyPlansStatus.initial,
    this.plans = const [],
    this.failure,
    this.message,
  });
  final DailyPlansStatus status;
  final List<DailyPlan> plans;
  final Failure? failure;
  final DailyPlansMessage? message;
  DailyPlansState copyWith({
    DailyPlansStatus? status,
    List<DailyPlan>? plans,
    Failure? failure,
    DailyPlansMessage? message,
    bool clearMessage = false,
  }) => DailyPlansState(
    status: status ?? this.status,
    plans: plans ?? this.plans,
    failure: failure,
    message: clearMessage ? null : message,
  );
  @override
  List<Object?> get props => [status, plans, failure, message];
}
