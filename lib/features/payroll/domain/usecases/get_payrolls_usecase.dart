import '../../../../core/usecases/usecase.dart';
import '../entities/payroll.dart';
import '../entities/payroll_filter.dart';
import '../repository/payroll_repository.dart';

/// [GetPayrollsUseCase] parametri: sahifa raqami + filtr.
typedef GetPayrollsParams = ({int page, PayrollFilter filter});

/// Ish haqi sahifasini olish (`GET /payroll/`).
class GetPayrollsUseCase implements UseCase<PayrollPage, GetPayrollsParams> {
  const GetPayrollsUseCase(this._repository);

  final PayrollRepository _repository;

  @override
  Future<PayrollPage> call(GetPayrollsParams params) =>
      _repository.getPayrolls(page: params.page, filter: params.filter);
}
