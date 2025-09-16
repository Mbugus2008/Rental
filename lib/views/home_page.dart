import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/data_controller.dart';
import '../controllers/theme_controller.dart';
import '../widgets/upload_form.dart';

class HomePage extends GetView<DataController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rental dashboard'),
        actions: <Widget>[
          Obx(
            () {
              final isDark = themeController.themeMode == ThemeMode.dark;
              return Row(
                children: <Widget>[
                  Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                  Switch(
                    value: isDark,
                    onChanged: themeController.toggleTheme,
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              const UploadForm(),
              const SizedBox(height: 16),
              Obx(
                () {
                  final message = controller.statusMessage.value;
                  if (message.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final isError = message.toLowerCase().contains('failed');
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isError
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isError
                                ? Theme.of(context).colorScheme.onErrorContainer
                                : Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(
                  () {
                    if (controller.isLoadingPosts.value && controller.posts.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.posts.isEmpty) {
                      return Center(
                        child: Text(
                          'No updates downloaded yet. Tap the refresh button to try again.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: controller.loadPosts,
                      child: ListView.separated(
                        itemCount: controller.posts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (BuildContext context, int index) {
                          final post = controller.posts[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    post.title,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    post.body,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Remote id: ${post.id}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(color: Theme.of(context).colorScheme.secondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: controller.isLoadingPosts.value ? null : controller.loadPosts,
          icon: controller.isLoadingPosts.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.refresh),
          label: Text(controller.isLoadingPosts.value ? 'Refreshing…' : 'Refresh'),
        ),
      ),
    );
  }
}
