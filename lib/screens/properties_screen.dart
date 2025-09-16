import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rental_provider.dart';
import '../widgets/add_property_form.dart';
import 'property_detail_screen.dart';

class PropertiesScreen extends StatelessWidget {
  const PropertiesScreen({super.key});

  static const routeName = '/properties';

  void _showAddPropertySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return AddPropertyForm(
          onSubmit: ({required name, required address, description}) {
            Provider.of<RentalProvider>(context, listen: false).addProperty(
              name: name,
              address: address,
              description: description,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RentalProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Properties'),
      ),
      body: provider.properties.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final property = provider.properties[index];
                final totalUnits = property.units.length;
                final occupied = property.occupiedUnitCount;
                final vacant = totalUnits - occupied;
                return Card(
                  child: ListTile(
                    title: Text(property.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.address),
                        const SizedBox(height: 4),
                        Text(
                          '$occupied occupied • $vacant vacant • $totalUnits total',
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                      context,
                      PropertyDetailScreen.routeName,
                      arguments: property.id,
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: provider.properties.length,
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPropertySheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Property'),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home_work_outlined, size: 72),
            const SizedBox(height: 16),
            Text(
              'No properties yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first property to start tracking units, tenants, and payments.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
