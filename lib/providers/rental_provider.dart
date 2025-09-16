import 'dart:math';

import 'package:flutter/material.dart';

import '../models/lease.dart';
import '../models/payment.dart';
import '../models/property.dart';
import '../models/rental_unit.dart';
import '../models/tenant.dart';
import '../models/tenant_lease_summary.dart';

class RentalProvider extends ChangeNotifier {
  final List<Property> _properties = <Property>[];
  int _idSeed = DateTime.now().millisecondsSinceEpoch;

  List<Property> get properties => List<Property>.unmodifiable(_properties);

  int get totalProperties => _properties.length;

  int get totalUnits => _properties.fold(
        0,
        (total, property) => total + property.units.length,
      );

  int get occupiedUnits => _properties.fold(
        0,
        (total, property) => total + property.occupiedUnitCount,
      );

  int get vacantUnits => totalUnits - occupiedUnits;

  double get projectedMonthlyIncome => _properties
      .expand((property) => property.units)
      .map((unit) => unit.currentLease?.monthlyRent ?? 0)
      .fold(0.0, (total, rent) => total + rent);

  List<Lease> get activeLeases => _properties
      .expand((property) => property.units)
      .expand((unit) => unit.leases)
      .where((lease) => lease.isActive)
      .toList();

  List<Payment> get overduePayments => activeLeases
      .expand((lease) => lease.payments)
      .where((payment) => payment.isOverdue)
      .toList()
    ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<Payment> get upcomingPayments {
    final now = DateTime.now();
    final horizon = now.add(const Duration(days: 30));
    final payments = activeLeases
        .expand((lease) => lease.payments)
        .where(
          (payment) => !payment.isPaid &&
              payment.dueDate.isAfter(now.subtract(const Duration(days: 1))) &&
              payment.dueDate.isBefore(horizon),
        )
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return payments;
  }

  List<Tenant> get tenants {
    final tenantMap = <String, Tenant>{};
    for (final lease in activeLeases) {
      tenantMap[lease.tenant.id] = lease.tenant;
    }
    return tenantMap.values.toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  List<TenantLeaseSummary> get tenantLeaseSummaries {
    final summaries = <TenantLeaseSummary>[];
    for (final property in _properties) {
      for (final unit in property.units) {
        final lease = unit.currentLease;
        if (lease != null && lease.isActive) {
          summaries.add(
            TenantLeaseSummary(
              tenant: lease.tenant,
              property: property,
              unit: unit,
              lease: lease,
            ),
          );
        }
      }
    }
    summaries.sort(
      (a, b) => a.tenant.fullName.compareTo(b.tenant.fullName),
    );
    return summaries;
  }

  Tenant createTenant({
    required String fullName,
    required String email,
    required String phone,
    String? notes,
  }) {
    return Tenant(
      id: _generateId(),
      fullName: fullName,
      email: email,
      phone: phone,
      notes: notes,
    );
  }

  void seedDemoData() {
    if (_properties.isNotEmpty) {
      return;
    }

    final tenantAlice = Tenant(
      id: _generateId(),
      fullName: 'Alice Walker',
      email: 'alice@example.com',
      phone: '+1 (555) 010-1234',
    );
    final tenantBrandon = Tenant(
      id: _generateId(),
      fullName: 'Brandon Smith',
      email: 'brandon@example.com',
      phone: '+1 (555) 010-2211',
    );

    final propertyDowntown = Property(
      id: _generateId(),
      name: 'Downtown Lofts',
      address: '120 Market Street, Springfield',
      description:
          'Modern loft-style units located within walking distance to downtown amenities.',
    );

    final loft101 = RentalUnit(
      id: _generateId(),
      name: 'Loft 101',
      bedrooms: 2,
      bathrooms: 1.5,
      monthlyRent: 1850,
      squareFeet: 980,
    );
    final loft102 = RentalUnit(
      id: _generateId(),
      name: 'Loft 102',
      bedrooms: 1,
      bathrooms: 1,
      monthlyRent: 1550,
      squareFeet: 780,
    );

    final leaseAlice = Lease(
      id: _generateId(),
      tenant: tenantAlice,
      unitId: loft101.id,
      propertyId: propertyDowntown.id,
      startDate: DateTime.now().subtract(const Duration(days: 120)),
      endDate: DateTime.now().add(const Duration(days: 245)),
      monthlyRent: 1850,
      deposit: 1850,
      payments: _buildPaymentSchedule(
        1850,
        start: DateTime.now().subtract(const Duration(days: 90)),
        months: 6,
      ),
    );
    loft101.leases.add(leaseAlice);
    if (leaseAlice.payments.isNotEmpty) {
      leaseAlice.payments.first.paidOn =
          leaseAlice.payments.first.dueDate.add(const Duration(days: 1));
    }

    final leaseBrandon = Lease(
      id: _generateId(),
      tenant: tenantBrandon,
      unitId: loft102.id,
      propertyId: propertyDowntown.id,
      startDate: DateTime.now().subtract(const Duration(days: 40)),
      endDate: DateTime.now().add(const Duration(days: 320)),
      monthlyRent: 1550,
      deposit: 1550,
      payments: _buildPaymentSchedule(
        1550,
        start: DateTime.now().subtract(const Duration(days: 30)),
        months: 6,
      ),
    );
    loft102.leases.add(leaseBrandon);
    if (leaseBrandon.payments.isNotEmpty) {
      leaseBrandon.payments.first.paidOn =
          leaseBrandon.payments.first.dueDate.add(const Duration(days: 2));
    }

    propertyDowntown.units.addAll(<RentalUnit>[loft101, loft102]);

    final propertySuburban = Property(
      id: _generateId(),
      name: 'Maplewood Villas',
      address: '45 Maple Avenue, Springfield',
      description:
          'Townhome community with spacious layouts and private garages.',
      units: <RentalUnit>[
        RentalUnit(
          id: _generateId(),
          name: 'Villa A',
          bedrooms: 3,
          bathrooms: 2.5,
          monthlyRent: 2200,
          squareFeet: 1500,
        ),
        RentalUnit(
          id: _generateId(),
          name: 'Villa B',
          bedrooms: 2,
          bathrooms: 2,
          monthlyRent: 1950,
          squareFeet: 1300,
        ),
      ],
    );

    _properties
      ..add(propertyDowntown)
      ..add(propertySuburban);
  }

  Property findPropertyById(String id) {
    return _properties.firstWhere((property) => property.id == id);
  }

  RentalUnit findUnitById(String propertyId, String unitId) {
    final property = findPropertyById(propertyId);
    return property.units.firstWhere((unit) => unit.id == unitId);
  }

  void addProperty({
    required String name,
    required String address,
    String? description,
  }) {
    final property = Property(
      id: _generateId(),
      name: name,
      address: address,
      description: description,
    );
    _properties.add(property);
    notifyListeners();
  }

  void addUnit(
    String propertyId, {
    required String name,
    required int bedrooms,
    required double bathrooms,
    required double monthlyRent,
    double? squareFeet,
  }) {
    final property = findPropertyById(propertyId);
    final unit = RentalUnit(
      id: _generateId(),
      name: name,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      monthlyRent: monthlyRent,
      squareFeet: squareFeet,
    );
    property.units.add(unit);
    notifyListeners();
  }

  void assignTenantToUnit(
    String propertyId,
    String unitId, {
    required Tenant tenant,
    required DateTime startDate,
    DateTime? endDate,
    required double monthlyRent,
    double deposit = 0,
  }) {
    final unit = findUnitById(propertyId, unitId);
    final lease = Lease(
      id: _generateId(),
      tenant: tenant,
      unitId: unitId,
      propertyId: propertyId,
      startDate: startDate,
      endDate: endDate,
      monthlyRent: monthlyRent,
      deposit: deposit,
      payments: _buildPaymentSchedule(
        monthlyRent,
        start: startDate,
        months: 3,
      ),
    );
    unit.leases.add(lease);
    notifyListeners();
  }

  void recordPayment(
    String propertyId,
    String unitId,
    String leaseId, {
    required double amount,
    required DateTime dueDate,
    DateTime? paidOn,
    String? notes,
  }) {
    final unit = findUnitById(propertyId, unitId);
    final lease = unit.leases.firstWhere((l) => l.id == leaseId);
    lease.payments.add(
      Payment(
        id: _generateId(),
        amount: amount,
        dueDate: dueDate,
        paidOn: paidOn,
        notes: notes,
      ),
    );
    notifyListeners();
  }

  void markPaymentAsPaid(
    String propertyId,
    String unitId,
    String leaseId,
    String paymentId,
  ) {
    final unit = findUnitById(propertyId, unitId);
    final lease = unit.leases.firstWhere((l) => l.id == leaseId);
    final payment = lease.payments.firstWhere((p) => p.id == paymentId);
    payment.paidOn = DateTime.now();
    notifyListeners();
  }

  List<Payment> _buildPaymentSchedule(
    double amount, {
    DateTime? start,
    int months = 1,
  }) {
    final now = start ?? DateTime.now();
    return List<Payment>.generate(months, (index) {
      final dueDate = DateTime(now.year, now.month + index + 1, 1);
      return Payment(
        id: _generateId(),
        amount: amount,
        dueDate: dueDate,
      );
    });
  }

  String _generateId() {
    _idSeed += Random().nextInt(7) + 1;
    return _idSeed.toString();
  }
}
