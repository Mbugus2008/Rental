import 'lease.dart';
import 'payment.dart';
import 'property.dart';
import 'rental_unit.dart';
import 'tenant.dart';

/// Convenience model that connects a tenant to their active lease context.
class TenantLeaseSummary {
  TenantLeaseSummary({
    required this.tenant,
    required this.property,
    required this.unit,
    required this.lease,
  });

  final Tenant tenant;
  final Property property;
  final RentalUnit unit;
  final Lease lease;

  Payment? get nextPayment => lease.nextPayment;
}
