import 'package:equatable/equatable.dart';

/// Vazifa formasidagi "Kimlar uchun" tanlovi — lavozim
/// (`GET /applications/positions/`).
class Position extends Equatable {
  const Position({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

/// Vazifa formasidagi "Loyiha" tanlovi — qisqa loyiha
/// (`GET /project-shorts/`). Dropdown'da sarlavha + tavsif + muddat ko'rsatiladi.
class ProjectShort extends Equatable {
  const ProjectShort({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
  });

  final int id;
  final String title;
  final String description;
  final DateTime? deadline;

  @override
  List<Object?> get props => [id, title, description, deadline];
}

/// Loyiha ishtirokchisi (`GET /projects/{id}/` — manager / created_by /
/// testers / employees). Topshiruvchi tanlovi shu ro'yxatdan olinadi; tanlangan
/// ishtirokchining [position]i "Kimlar uchun" maydoniga yoziladi.
class ProjectMember extends Equatable {
  const ProjectMember({
    required this.id,
    required this.username,
    required this.position,
  });

  final int id;
  final String username;
  final String position;

  @override
  List<Object?> get props => [id, username, position];
}

/// Formani to‘ldirish uchun bir martada (parallel) yuklanadigan tanlov
/// ro‘yxatlari: lavozimlar + qisqa loyihalar.
typedef TaskFormOptions =
    ({List<Position> positions, List<ProjectShort> projects});
