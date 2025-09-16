import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/property.dart';
import '../models/rental_unit.dart';
import '../providers/rental_provider.dart';
import '../utils/formatting.dart';
import '../widgets/add_unit_form.dart';
import 'unit_detail_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.property});

  static const routeName = '/property';

  final Property property;

  void _openAddUnitSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddUnitForm(
          onSubmit: ({
            required name,
            required bedrooms,
            required double bathrooms,
            required double monthlyRent,
            double? squareFeet,
          }) {
            Provider.of<RentalProvider>(context, listen: false).addUnit(
              property.id,
              name: name,
              bedrooms: bedrooms,
              bathrooms: bathrooms,
              monthlyRent: monthlyRent,
              squareFeet: squareFeet,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();
    final latestProperty = provider.findPropertyById(property.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(latestProperty.name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddUnitSheet(context),
        icon: const Icon(Icons.add_home_work_outlined),
        label: const Text('Unit'),
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
                      latestProperty.address,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if ((latestProperty.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(latestProperty.description!),
                    ],
                    const SizedBox(height: 12),
                    Text(
                      '${latestProperty.occupiedUnitCount} occupied • ${latestProperty.vacantUnitCount} vacant',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Units',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (latestProperty.units.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No units yet. Add one using the button below.'),
                ),
              )
            else
              ...latestProperty.units.map(
                (unit) => _UnitTile(
                  propertyId: latestProperty.id,
                  unit: unit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _UnitTile extends StatelessWidget {
  const _UnitTile({required this.propertyId, required this.unit});

  final String propertyId;
  final RentalUnit unit;

  @override
  Widget build(BuildContext context) {
    final lease = unit.currentLease;
    final subtitle = lease == null
        ? 'Vacant • Rent ${formatCurrency(unit.monthlyRent)}'
        : '${lease.tenant.fullName} • Rent ${formatCurrency(lease.monthlyRent)}';
    return Card(
      child: ListTile(
        leading: Icon(
          lease == null ? Icons.door_front_door_outlined : Icons.person_outline,
        ),
        title: Text(unit.name),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(
          context,
          UnitDetailScreen.routeName,
          arguments: UnitDetailArguments(
            propertyId: propertyId,
            unitId: unit.id,
          ),
        ),
      ),
    );
  }
}
