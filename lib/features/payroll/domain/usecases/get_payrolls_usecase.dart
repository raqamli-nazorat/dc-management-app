import '../../../../core/usecases/usecase.dart';
import '../entities/payroll.dart';
import '../repository/payroll_repository.dart';

/// [GetPayrollsUseCase] parametri: sahifa raqami + qidiruv matni.
typedef GetPayrollsParams = ({int page, String search});

/// Ish haqi sahifasini olish (`GET /payroll/`).
class GetPayrollsUseCase implements UseCase<PayrollPage, GetPayrollsParams> {
  const GetPayrollsUseCase(this._repository);

  final PayrollRepository _repository;

  @override
  Future<PayrollPage> call(GetPayrollsParams params) =>
      _repository.getPayrolls(page: params.page, search: params.search);
}
