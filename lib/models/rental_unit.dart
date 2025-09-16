import 'lease.dart';

class RentalUnit {
  RentalUnit({
    required this.id,
    required this.name,
    required this.bedrooms,
    required this.bathrooms,
    required this.monthlyRent,
    this.squareFeet,
    List<Lease>? leases,
  }) : leases = leases ?? <Lease>[];

  final String id;
  final String name;
  final int bedrooms;
  final double bathrooms;
  final double monthlyRent;
  final double? squareFeet;
  final List<Lease> leases;

  bool get isOccupied => leases.any((lease) => lease.isActive);

  Lease? get currentLease {
    try {
      return leases.firstWhere((lease) => lease.isActive);
    } catch (_) {
      return null;
    }
  }
}
