import '../entities/payroll.dart';
import '../entities/payroll_filter.dart';

/// Ish haqi domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class PayrollRepository {
  /// Bitta sahifa (`GET /payroll/?page=` + filtr paramlari).
  Future<PayrollPage> getPayrolls({int page, PayrollFilter filter});

  /// Bitta yozuv (`GET /payroll/{id}/`).
  Future<Payroll> getPayroll(int id);

  /// Yozuv(lar)ni tasdiqlash (`POST /payroll/confirm/` — `{payroll_ids}`).
  Future<void> confirmPayrolls(List<int> ids);
}
