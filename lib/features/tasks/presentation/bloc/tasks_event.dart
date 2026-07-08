part of 'tasks_bloc.dart';

sealed class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

/// Ro'yxatni yuklash / qayta yuklash (1-sahifadan, joriy filtr bilan).
class TasksRequested extends TasksEvent {
  const TasksRequested();
}

/// Keyingi sahifani yuklab, ro'yxat oxiriga qo'shish (cheksiz-scroll).
class TasksLoadMore extends TasksEvent {
  const TasksLoadMore();
}

/// Filtr o'zgardi (filtr sahifasidan) — mavjud qidiruv matni saqlanib, 1-sahifa
/// qaytadan yuklanadi.
class TasksFilterChanged extends TasksEvent {
  const TasksFilterChanged(this.filter);

  final TaskFilter filter;

  @override
  List<Object?> get props => [filter];
}

/// Qidiruv matni o'zgardi (sarlavhadagi qidiruv paneli) — boshqa filtrlar
/// saqlanib, 1-sahifa qaytadan yuklanadi.
class TasksSearchChanged extends TasksEvent {
  const TasksSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Vazifa o'chirildi (karta menyusidan) — optimistik ravishda ro'yxatdan
/// olib tashlanadi.
class TasksTaskDeleted extends TasksEvent {
  const TasksTaskDeleted(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
