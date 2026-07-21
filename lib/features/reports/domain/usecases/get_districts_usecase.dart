import '../../../../core/usecases/usecase.dart';
import '../entities/user_report_filter.dart';
import '../repository/reports_repository.dart';

/// Tanlangan viloyat tumanlarini olish.
class GetDistrictsUseCase implements UseCase<List<District>, int> {
  const GetDistrictsUseCase(this._repository);

  final ReportsRepository _repository;

  @override
  Future<List<District>> call(int regionId) =>
      _repository.getDistricts(regionId: regionId);
}
