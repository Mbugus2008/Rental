import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lease.dart';
import '../models/payment.dart';
import '../models/property.dart';
import '../models/rental_unit.dart';
import '../providers/rental_provider.dart';
import '../utils/formatting.dart';
import '../widgets/assign_tenant_form.dart';
import '../widgets/payment_form.dart';

class UnitDetailArguments {
  UnitDetailArguments({required this.propertyId, required this.unitId});

  final String propertyId;
  final String unitId;
}

class UnitDetailScreen extends StatelessWidget {
  const UnitDetailScreen({super.key, required this.propertyId, required this.unitId});

  static const routeName = '/unit';

  final String propertyId;
  final String unitId;

  void _showAssignTenantSheet(BuildContext context, RentalUnit unit) {
    final provider = Provider.of<RentalProvider>(context, listen: false);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AssignTenantForm(
          suggestedRent: unit.monthlyRent,
          onSubmit: ({
            required String fullName,
            required String email,
            required String phone,
            String? notes,
            required DateTime startDate,
            DateTime? endDate,
            required double rent,
            double deposit = 0,
          }) {
            final tenant = provider.createTenant(
              fullName: fullName,
              email: email,
              phone: phone,
              notes: notes,
            );
            provider.assignTenantToUnit(
              propertyId,
              unitId,
              tenant: tenant,
              startDate: startDate,
              endDate: endDate,
              monthlyRent: rent,
              deposit: deposit,
            );
          },
        );
      },
    );
  }

  void _showPaymentSheet(BuildContext context, Lease lease) {
    final provider = Provider.of<RentalProvider>(context, listen: false);
    final nextDueDate = lease.nextPayment?.dueDate ?? DateTime.now().add(const Duration(days: 30));
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return RecordPaymentForm(
          initialDueDate: nextDueDate,
          onSubmit: ({
            required double amount,
            required DateTime dueDate,
            bool markAsPaid = false,
            String? notes,
          }) {
            provider.recordPayment(
              propertyId,
              unitId,
              lease.id,
              amount: amount,
              dueDate: dueDate,
              paidOn: markAsPaid ? DateTime.now() : null,
              notes: notes,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RentalProvider>(
      builder: (context, provider, child) {
        final Property property = provider.findPropertyById(propertyId);
        final RentalUnit unit = provider.findUnitById(propertyId, unitId);
        final Lease? lease = unit.currentLease;
        final payments = lease?.payments.toList() ?? <Payment>[];
        payments.sort((a, b) => a.dueDate.compareTo(b.dueDate));

        return Scaffold(
          appBar: AppBar(
            title: Text('${property.name} • ${unit.name}'),
          ),
          floatingActionButton: lease == null
              ? FloatingActionButton.extended(
                  onPressed: () => _showAssignTenantSheet(context, unit),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Assign tenant'),
                )
              : FloatingActionButton.extended(
                  onPressed: () => _showPaymentSheet(context, lease),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Add payment'),
                ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unit.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${unit.bedrooms} bed • ${unit.bathrooms.toStringAsFixed(1)} bath • ${formatCurrency(unit.monthlyRent)} /mo',
                        ),
                        if (unit.squareFeet != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text('${unit.squareFeet!.toStringAsFixed(0)} sq ft'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (lease == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vacant unit',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Assign a tenant to start tracking a lease and payment schedule.',
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () => _showAssignTenantSheet(context, unit),
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Assign tenant'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current lease',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _LeaseDetailRow(
                            label: 'Tenant',
                            value: lease.tenant.fullName,
                          ),
                          _LeaseDetailRow(
                            label: 'Start date',
                            value: formatDate(lease.startDate),
                          ),
                          if (lease.endDate != null)
                            _LeaseDetailRow(
                              label: 'End date',
                              value: formatDate(lease.endDate!),
                            ),
                          _LeaseDetailRow(
                            label: 'Monthly rent',
                            value: formatCurrency(lease.monthlyRent),
                          ),
                          _LeaseDetailRow(
                            label: 'Security deposit',
                            value: formatCurrency(lease.deposit),
                          ),
                          if (lease.balanceDue > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Balance due: ${formatCurrency(lease.balanceDue)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.redAccent),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Payments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                if (lease == null)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No payments yet. Assign a tenant to generate a schedule.'),
                    ),
                  )
                else if (payments.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No recorded payments for this lease.'),
                    ),
                  )
                else
                  ...payments.map(
                    (payment) => Card(
                      child: ListTile(
                        leading: Icon(
                          payment.isPaid
                              ? Icons.check_circle_outlined
                              : (payment.isOverdue
                                  ? Icons.warning_amber_outlined
                                  : Icons.schedule_outlined),
                          color: payment.isPaid
                              ? Colors.green
                              : (payment.isOverdue ? Colors.redAccent : null),
                        ),
                        title: Text(
                          formatCurrency(payment.amount),
                        ),
                        subtitle: Text(
                          [
                            'Due ${formatDate(payment.dueDate)}',
                            if (payment.paidOn != null)
                              'Paid ${formatDate(payment.paidOn!)}',
                          ].join('\n'),
                        ),
                        trailing: !payment.isPaid
                            ? TextButton(
                                onPressed: () => provider.markPaymentAsPaid(
                                  propertyId,
                                  unitId,
                                  lease.id,
                                  payment.id,
                                ),
                                child: const Text('Mark paid'),
                              )
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LeaseDetailRow extends StatelessWidget {
  const _LeaseDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

