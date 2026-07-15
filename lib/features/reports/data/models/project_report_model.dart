import '../../../../core/util/lenient_json.dart';
import '../../../projects/domain/entities/project.dart';
import '../../domain/entities/project_report.dart';

/// [ProjectReport] uchun JSON mapping (`GET /reports/projects/`).
class ProjectReportModel extends ProjectReport {
  const ProjectReportModel({
    required super.id,
    required super.prefix,
    required super.title,
    required super.description,
    required super.deadline,
    required super.status,
    required super.projectPrice,
    required super.createdByName,
    required super.managerName,
    required super.employeesNames,
    required super.testersNames,
    required super.taskStats,
  });

  factory ProjectReportModel.fromJson(Map<String, dynamic> json) =>
      ProjectReportModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        prefix: json['prefix'] as String? ?? '',
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        deadline: DateTime.tryParse(json['deadline'] as String? ?? ''),
        status: ProjectStatus.fromApi(json['status'] as String?),
        projectPrice: _asNum(json['project_price']),
        createdByName: json['created_by_name'] as String? ?? '',
        managerName: json['manager_name'] as String? ?? '',
        employeesNames: json['employees_names'] as String? ?? '',
        testersNames: json['testers_names'] as String? ?? '',
        taskStats: _parseTaskStats(json['task_stats']),
      );

  static num _asNum(Object? value) {
    if (value is num) return value;
    if (value is String) return num.tryParse(value) ?? 0;
    return 0;
  }

  /// `task_stats` — schema bo'yicha tipsiz `string`; haqiqiy shakli
  /// tasdiqlanmagan. Avval JSON obyekt sifatida o'qishga urinamiz (xom
  /// qiymat allaqachon `Map` bo'lishi mumkin yoki JSON-string bo'lishi
  /// mumkin), muvaffaqiyatsiz bo'lsa — inson o'qiydigan matn deb hisoblab,
  /// "Yorliq: son" naqshlarini regex bilan ajratib olamiz (Figma dizaynida
  /// shu ko'rinishda). Kalit nomlari/naqsh taxminiy — real javobga qarab
  /// moslashtirish kerak.
  static ProjectTaskStats _parseTaskStats(Object? raw) {
    final Map<String, dynamic>? map = switch (raw) {
      Map<String, dynamic> m => m,
      Map m => m.cast<String, dynamic>(),
      String s => lenientJsonDecode(s),
      _ => null,
    };
    if (map != null) {
      int asInt(List<String> keys) {
        for (final key in keys) {
          final value = map[key];
          if (value is num) return value.toInt();
        }
        return 0;
      }

      return ProjectTaskStats(
        todo: asInt(['todo']),
        inProgress: asInt(['in_progress', 'inProgress']),
        done: asInt(['done']),
        production: asInt(['production']),
        checked: asInt(['checked']),
        rejected: asInt(['rejected']),
        overdue: asInt(['overdue']),
      );
    }

    if (raw is String && raw.isNotEmpty) {
      int fromLabel(String label) {
        final match = RegExp(
          '$label[^0-9]*(\\d+)',
          caseSensitive: false,
        ).firstMatch(raw);
        return int.tryParse(match?.group(1) ?? '') ?? 0;
      }

      return ProjectTaskStats(
        todo: fromLabel('Qilish kerak'),
        inProgress: fromLabel('Jarayonda'),
        done: fromLabel('Bajarilgan'),
        production: fromLabel('Ishga tush'),
        checked: fromLabel('Tekshirilgan'),
        rejected: fromLabel('Rad etilgan'),
        overdue: fromLabel('Muddati'),
      );
    }

    return ProjectTaskStats.empty;
  }
}
