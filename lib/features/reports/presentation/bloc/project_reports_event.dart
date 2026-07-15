part of 'project_reports_bloc.dart';

sealed class ProjectReportsEvent extends Equatable {
  const ProjectReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class ProjectReportsRequested extends ProjectReportsEvent {
  const ProjectReportsRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class ProjectReportsLoadMore extends ProjectReportsEvent {
  const ProjectReportsLoadMore();
}

/// Qidiruv matni o'zgardi — boshqa filtrlar saqlanib, 1-sahifa qaytadan
/// yuklanadi.
class ProjectReportsSearchChanged extends ProjectReportsEvent {
  const ProjectReportsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib,
/// 1-sahifa qaytadan yuklanadi.
class ProjectReportsFilterChanged extends ProjectReportsEvent {
  const ProjectReportsFilterChanged(this.filter);

  final ProjectReportFilter filter;

  @override
  List<Object?> get props => [filter];
}
