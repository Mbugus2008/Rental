import 'payment.dart';
import 'tenant.dart';

class Lease {
  Lease({
    required this.id,
    required this.tenant,
    required this.unitId,
    required this.propertyId,
    required this.startDate,
    this.endDate,
    required this.monthlyRent,
    this.deposit = 0,
    List<Payment>? payments,
  }) : payments = payments ?? <Payment>[];

  final String id;
  final Tenant tenant;
  final String unitId;
  final String propertyId;
  final DateTime startDate;
  DateTime? endDate;
  final double monthlyRent;
  final double deposit;
  final List<Payment> payments;

  bool get isActive => endDate == null || endDate!.isAfter(DateTime.now());

  Payment? get nextPayment {
    final pending = payments
        .where((payment) => !payment.isPaid)
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return pending.isEmpty ? null : pending.first;
  }

  double get balanceDue => payments
      .where((payment) => !payment.isPaid)
      .fold(0.0, (total, payment) => total + payment.amount);
}
