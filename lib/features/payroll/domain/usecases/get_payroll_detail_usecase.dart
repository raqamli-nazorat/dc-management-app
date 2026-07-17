import '../../../../core/usecases/usecase.dart';
import '../entities/payroll.dart';
import '../repository/payroll_repository.dart';

/// Bitta ish haqi yozuvini olish (`GET /payroll/{id}/`).
class GetPayrollDetailUseCase implements UseCase<Payroll, int> {
  const GetPayrollDetailUseCase(this._repository);

  final PayrollRepository _repository;

  @override
  Future<Payroll> call(int id) => _repository.getPayroll(id);
}
