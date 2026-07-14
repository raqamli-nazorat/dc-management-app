import '../../../../core/usecases/usecase.dart';
import '../entities/user_report_filter.dart';
import '../repository/reports_repository.dart';

/// Viloyatlar ro'yxatini olish (`GET /applications/regions/`) — filtr
/// "Viloyat" tanlovi uchun.
class GetRegionsUseCase implements UseCase<List<Region>, void> {
  const GetRegionsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<List<Region>> call([void params]) => _repository.getRegions();
}
