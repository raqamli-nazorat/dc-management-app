part of 'reports_filter_bloc.dart';

sealed class ReportsFilterEvent extends Equatable {
  const ReportsFilterEvent();

  @override
  List<Object?> get props => [];
}

/// Tanlov ro'yxatlarini (lavozim/viloyat/foydalanuvchi) yuklash.
class ReportsFilterOptionsRequested extends ReportsFilterEvent {
  const ReportsFilterOptionsRequested();
}
