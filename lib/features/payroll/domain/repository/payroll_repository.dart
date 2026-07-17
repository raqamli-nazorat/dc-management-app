import '../entities/payroll.dart';

/// Ish haqi domen shartnomasi. Implementatsiya `Exception`larni `Failure`ga
/// aylantiradi (bloclar `Failure` ustida ishlaydi).
abstract interface class PayrollRepository {
  /// Bitta sahifa (`GET /payroll/?page=&search=`).
  Future<PayrollPage> getPayrolls({int page, String search});

  /// Bitta yozuv (`GET /payroll/{id}/`).
  Future<Payroll> getPayroll(int id);

  /// Yozuv(lar)ni tasdiqlash (`POST /payroll/confirm/` — `{payroll_ids}`).
  Future<void> confirmPayrolls(List<int> ids);
}
