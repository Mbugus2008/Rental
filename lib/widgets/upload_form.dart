import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_controller.dart';

class UploadForm extends GetView<DataController> {
  const UploadForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Upload property update',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.titleController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: controller.bodyController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide some details';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Obx(
                () => Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () => controller.submitPost(),
                    icon: controller.isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: Text(
                      controller.isSubmitting.value ? 'Uploading…' : 'Upload update',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
