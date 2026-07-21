import '../../domain/entities/user_report_filter.dart';

/// [District] uchun JSON mapping (`GET /applications/districts/`).
class DistrictModel extends District {
  const DistrictModel({
    required super.id,
    required super.name,
    required super.regionId,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) => DistrictModel(
    id: (json['id'] as num?)?.toInt() ?? 0,
    name: json['name'] as String? ?? '',
    regionId: (json['region'] as num?)?.toInt() ?? 0,
  );
}
