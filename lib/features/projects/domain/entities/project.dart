import 'package:equatable/equatable.dart';

typedef ProjectPage = ({List<Project> items, int totalCount, bool hasMore});

enum ProjectStatus {
  planning,
  active,
  overdue,
  completed,
  cancelled,
  unknown;

  static ProjectStatus fromApi(String? value) => switch (value) {
    'planning' => ProjectStatus.planning,
    'active' => ProjectStatus.active,
    'overdue' => ProjectStatus.overdue,
    'completed' => ProjectStatus.completed,
    'cancelled' => ProjectStatus.cancelled,
    _ => ProjectStatus.unknown,
  };

  String? get apiValue => switch (this) {
    ProjectStatus.planning => 'planning',
    ProjectStatus.active => 'active',
    ProjectStatus.overdue => 'overdue',
    ProjectStatus.completed => 'completed',
    ProjectStatus.cancelled => 'cancelled',
    ProjectStatus.unknown => null,
  };
}

class ProjectParticipant extends Equatable {
  const ProjectParticipant({
    required this.id,
    required this.username,
    required this.position,
    required this.avatar,
  });

  final int id;
  final String username;
  final String position;
  final String avatar;

  String get initials {
    final words = username
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';
    String first(String value) => String.fromCharCode(value.runes.first);
    if (words.length == 1) {
      return String.fromCharCodes(words.first.runes.take(2));
    }
    return '${first(words.first)}${first(words.last)}';
  }

  @override
  List<Object?> get props => [id, username, position];
}

class Project extends Equatable {
  const Project({
    required this.id,
    required this.uid,
    required this.prefix,
    required this.title,
    required this.description,
    required this.manager,
    required this.createdBy,
    required this.testers,
    required this.employees,
    required this.deadline,
    required this.status,
    required this.isHidden,
    required this.createdAt,
    required this.updatedAt,
    required this.completionPercentage,
    this.projectPrice = '',
    this.penaltyPercentage = '',
  });

  final int id;
  final String uid;
  final String prefix;
  final String title;
  final String description;
  final ProjectParticipant? manager;
  final ProjectParticipant? createdBy;
  final List<ProjectParticipant> testers;
  final List<ProjectParticipant> employees;
  final DateTime? deadline;
  final ProjectStatus status;
  final bool isHidden;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String completionPercentage;
  final String projectPrice;
  final String penaltyPercentage;

  @override
  List<Object?> get props => [
    id,
    uid,
    prefix,
    title,
    description,
    manager,
    createdBy,
    testers,
    employees,
    deadline,
    status,
    isHidden,
    createdAt,
    updatedAt,
    completionPercentage,
    projectPrice,
    penaltyPercentage,
  ];
}
