import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rental_provider.dart';
import '../utils/formatting.dart';
import '../widgets/stat_card.dart';
import 'properties_screen.dart';
import 'tenant_directory_screen.dart';
import 'unit_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Tenants',
            onPressed: () =>
                Navigator.pushNamed(context, TenantDirectoryScreen.routeName),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                StatCard(
                  title: 'Properties',
                  value: provider.totalProperties.toString(),
                  icon: Icons.apartment,
                ),
                StatCard(
                  title: 'Units',
                  value: provider.totalUnits.toString(),
                  icon: Icons.home_work_outlined,
                ),
                StatCard(
                  title: 'Occupied',
                  value: provider.occupiedUnits.toString(),
                  icon: Icons.check_circle_outline,
                ),
                StatCard(
                  title: 'Vacant',
                  value: provider.vacantUnits.toString(),
                  icon: Icons.hourglass_empty,
                ),
                StatCard(
                  title: 'Monthly Income',
                  value: formatCurrency(provider.projectedMonthlyIncome),
                  icon: Icons.payments_outlined,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, PropertiesScreen.routeName),
              icon: const Icon(Icons.list_alt),
              label: const Text('Manage Properties'),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Upcoming Payments',
              action: provider.upcomingPayments.isNotEmpty
                  ? Text('${provider.upcomingPayments.length} due in 30 days')
                  : const Text('Nothing due soon'),
            ),
            const SizedBox(height: 8),
            if (provider.upcomingPayments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No upcoming payments within the next 30 days.',
                  ),
                ),
              )
            else
              ...provider.upcomingPayments.map(
                (payment) => Card(
                  child: ListTile(
                    title: Text('${formatCurrency(payment.amount)} due'),
                    subtitle: Text(
                      'Due ${formatDate(payment.dueDate)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: () {
                        final lease = provider.activeLeases.firstWhere(
                          (lease) => lease.payments.contains(payment),
                        );
                        provider.markPaymentAsPaid(
                          lease.propertyId,
                          lease.unitId,
                          lease.id,
                          payment.id,
                        );
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Overdue Payments',
              action: provider.overduePayments.isEmpty
                  ? const Text('All caught up')
                  : Text('${provider.overduePayments.length} overdue'),
            ),
            const SizedBox(height: 8),
            if (provider.overduePayments.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No overdue payments at the moment.'),
                ),
              )
            else
              ...provider.overduePayments.map(
                (payment) {
                  final lease = provider.activeLeases.firstWhere(
                    (lease) => lease.payments.contains(payment),
                  );
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber_outlined),
                      title: Text(
                        '${formatCurrency(payment.amount)} from ${lease.tenant.fullName}',
                      ),
                      subtitle: Text(
                        'Due ${formatDate(payment.dueDate)} • ${lease.unitId}',
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        UnitDetailScreen.routeName,
                        arguments: UnitDetailArguments(
                          propertyId: lease.propertyId,
                          unitId: lease.unitId,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (action != null)
          DefaultTextStyle(
            style: theme.textTheme.bodyMedium!,
            child: action!,
          ),
      ],
    );
  }
}

