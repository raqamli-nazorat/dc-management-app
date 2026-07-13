part of 'project_create_bloc.dart';

enum ProjectCreateSubmitStatus { idle, submitting, success, failure }

class ProjectCreateState extends Equatable {
  const ProjectCreateState({
    this.optionsLoading = false,
    this.users = const [],
    this.managers = const [],
    this.submitStatus = ProjectCreateSubmitStatus.idle,
    this.submitFailure,
    this.project,
    this.documentsFailed = false,
    this.documents = const [],
    this.documentsLoading = false,
  });

  final bool optionsLoading;
  final List<UserShort> users;
  final List<UserShort> managers;
  final ProjectCreateSubmitStatus submitStatus;
  final Failure? submitFailure;
  final Project? project;

  /// Loyiha yaratildi, lekin ba'zi hujjatlar yuklanmadi.
  final bool documentsFailed;
  final List<ProjectDocument> documents;
  final bool documentsLoading;

  ProjectCreateState copyWith({
    bool? optionsLoading,
    List<UserShort>? users,
    List<UserShort>? managers,
    ProjectCreateSubmitStatus? submitStatus,
    Failure? submitFailure,
    Project? project,
    bool? documentsFailed,
    List<ProjectDocument>? documents,
    bool? documentsLoading,
  }) => ProjectCreateState(
    optionsLoading: optionsLoading ?? this.optionsLoading,
    users: users ?? this.users,
    managers: managers ?? this.managers,
    submitStatus: submitStatus ?? this.submitStatus,
    submitFailure: submitFailure,
    project: project ?? this.project,
    documentsFailed: documentsFailed ?? this.documentsFailed,
    documents: documents ?? this.documents,
    documentsLoading: documentsLoading ?? this.documentsLoading,
  );

  @override
  List<Object?> get props => [
    optionsLoading,
    users,
    managers,
    submitStatus,
    submitFailure,
    project,
    documentsFailed,
    documents,
    documentsLoading,
  ];
}
