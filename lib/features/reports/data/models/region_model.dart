import '../../domain/entities/user_report_filter.dart';

/// [Region] uchun JSON mapping (`GET /applications/regions/`).
class RegionModel extends Region {
  const RegionModel({required super.id, required super.name});

  factory RegionModel.fromJson(Map<String, dynamic> json) => RegionModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
  );
}
