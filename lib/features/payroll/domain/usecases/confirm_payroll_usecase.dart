import '../../../../core/usecases/usecase.dart';
import '../repository/payroll_repository.dart';

/// Ish haqi yozuvini tasdiqlash (`POST /payroll/confirm/`).
class ConfirmPayrollUseCase implements UseCase<void, int> {
  const ConfirmPayrollUseCase(this._repository);

  final PayrollRepository _repository;

  @override
  Future<void> call(int id) => _repository.confirmPayrolls([id]);
}
