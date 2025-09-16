import 'package:flutter/material.dart';

typedef UnitSubmitCallback = void Function({
  required String name,
  required int bedrooms,
  required double bathrooms,
  required double monthlyRent,
  double? squareFeet,
});

class AddUnitForm extends StatefulWidget {
  const AddUnitForm({super.key, required this.onSubmit});

  final UnitSubmitCallback onSubmit;

  @override
  State<AddUnitForm> createState() => _AddUnitFormState();
}

class _AddUnitFormState extends State<AddUnitForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _rentController = TextEditingController();
  final _sizeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _rentController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bedrooms = int.tryParse(_bedroomsController.text.trim()) ?? 0;
    final bathrooms = double.tryParse(_bathroomsController.text.trim()) ?? 0;
    final rent = double.tryParse(_rentController.text.trim()) ?? 0;
    final size = double.tryParse(_sizeController.text.trim());

    widget.onSubmit(
      name: _nameController.text.trim(),
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      monthlyRent: rent,
      squareFeet: size,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: viewInsets.bottom + 16,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Unit',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Unit name or number'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    decoration: const InputDecoration(labelText: 'Bedrooms'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final parsed = int.tryParse(value ?? '');
                      if (parsed == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    decoration: const InputDecoration(labelText: 'Bathrooms'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final parsed = double.tryParse(value ?? '');
                      if (parsed == null) {
                        return 'Enter a number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentController,
              decoration: const InputDecoration(labelText: 'Monthly rent'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final parsed = double.tryParse(value ?? '');
                if (parsed == null) {
                  return 'Enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizeController,
              decoration: const InputDecoration(
                labelText: 'Square feet (optional)',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _handleSubmit,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
