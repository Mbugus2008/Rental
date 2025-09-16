import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rental_provider.dart';
import '../utils/formatting.dart';

class TenantDirectoryScreen extends StatelessWidget {
  const TenantDirectoryScreen({super.key});

  static const routeName = '/tenants';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenants'),
      ),
      body: Consumer<RentalProvider>(
        builder: (context, provider, child) {
          final summaries = provider.tenantLeaseSummaries;
          if (summaries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text('No tenants assigned yet.'),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final summary = summaries[index];
              final tenant = summary.tenant;
              final lease = summary.lease;
              final nextPayment = summary.nextPayment;
              final theme = Theme.of(context);
              final statusColor = nextPayment?.isOverdue == true
                  ? Colors.redAccent
                  : theme.colorScheme.primary;

              return Card(
                child: ListTile(
                  isThreeLine: true,
                  leading: CircleAvatar(
                    child: Text(
                      tenant.fullName.isNotEmpty
                          ? tenant.fullName.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(tenant.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tenant.email),
                      Text(tenant.phone),
                      const SizedBox(height: 4),
                      Text(
                        '${summary.property.name} • ${summary.unit.name}',
                      ),
                      Text('Lease started ${formatDate(lease.startDate)}'),
                      if (lease.endDate != null)
                        Text('Ends ${formatDate(lease.endDate!)}'),
                      if (tenant.notes != null && tenant.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(tenant.notes!),
                        ),
                    ],
                  ),
                  trailing: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          nextPayment != null
                              ? formatCurrency(nextPayment.amount)
                              : 'No balance',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                        Text(
                          nextPayment == null
                              ? 'All paid'
                              : '${nextPayment.isOverdue ? 'Overdue' : 'Due'} ${formatDate(nextPayment.dueDate)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: summaries.length,
          );
        },
      ),
    );
  }
}
