import 'package:equatable/equatable.dart';

typedef ExpenseReportPage = ({List<ExpenseReport> items, bool hasMore});

enum ExpensePaymentMethod {
  cash,
  card,
  unknown;

  static ExpensePaymentMethod fromApi(String? value) => switch (value) {
    'cash' => ExpensePaymentMethod.cash,
    'card' => ExpensePaymentMethod.card,
    _ => ExpensePaymentMethod.unknown,
  };

  String? get apiValue => switch (this) {
    ExpensePaymentMethod.cash => 'cash',
    ExpensePaymentMethod.card => 'card',
    ExpensePaymentMethod.unknown => null,
  };
}

enum ExpenseStatus {
  pending,
  paid,
  confirmed,
  cancelled,
  unknown;

  static ExpenseStatus fromApi(String? value) => switch (value) {
    'pending' => ExpenseStatus.pending,
    'paid' => ExpenseStatus.paid,
    'confirmed' => ExpenseStatus.confirmed,
    'cancelled' => ExpenseStatus.cancelled,
    _ => ExpenseStatus.unknown,
  };

  String? get apiValue => switch (this) {
    ExpenseStatus.pending => 'pending',
    ExpenseStatus.paid => 'paid',
    ExpenseStatus.confirmed => 'confirmed',
    ExpenseStatus.cancelled => 'cancelled',
    ExpenseStatus.unknown => null,
  };
}

enum ExpenseType {
  withdrawal,
  company,
  other,
  unknown;

  static ExpenseType fromApi(String? value) => switch (value) {
    'withdrawal' => ExpenseType.withdrawal,
    'company' => ExpenseType.company,
    'other' => ExpenseType.other,
    _ => ExpenseType.unknown,
  };

  String? get apiValue => switch (this) {
    ExpenseType.withdrawal => 'withdrawal',
    ExpenseType.company => 'company',
    ExpenseType.other => 'other',
    ExpenseType.unknown => null,
  };
}

class ExpenseReport extends Equatable {
  const ExpenseReport({
    required this.id,
    required this.user,
    required this.accountant,
    required this.project,
    required this.type,
    required this.expenseCategory,
    required this.amount,
    required this.reason,
    required this.cancelReason,
    required this.paymentMethod,
    required this.cardNumber,
    required this.status,
    required this.createdAt,
    required this.paidAt,
    required this.confirmedAt,
    required this.cancelledAt,
  });

  final int id;
  final String user;
  final String accountant;
  final String project;
  final ExpenseType type;
  final String expenseCategory;
  final num amount;
  final String reason;
  final String cancelReason;
  final ExpensePaymentMethod paymentMethod;
  final String cardNumber;
  final ExpenseStatus status;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final DateTime? confirmedAt;
  final DateTime? cancelledAt;

  @override
  List<Object?> get props => [
    id,
    user,
    accountant,
    project,
    type,
    expenseCategory,
    amount,
    reason,
    cancelReason,
    paymentMethod,
    cardNumber,
    status,
    createdAt,
    paidAt,
    confirmedAt,
    cancelledAt,
  ];
}
