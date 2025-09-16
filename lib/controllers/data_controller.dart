import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/remote_post.dart';
import '../services/api_service.dart';

class DataController extends GetxController {
  DataController({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  final RxList<RemotePost> posts = <RemotePost>[].obs;
  final RxBool isLoadingPosts = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString statusMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadPosts();
  }

  Future<void> loadPosts() async {
    if (isLoadingPosts.value) {
      return;
    }

    isLoadingPosts.value = true;
    statusMessage.value = '';
    try {
      final downloadedPosts = await _apiService.fetchPosts(limit: 10);
      posts.assignAll(downloadedPosts);
      statusMessage.value = 'Downloaded ${downloadedPosts.length} updates from the server.';
    } catch (error) {
      statusMessage.value = 'Download failed: $error';
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> submitPost() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid || isSubmitting.value) {
      return;
    }

    isSubmitting.value = true;
    statusMessage.value = '';

    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    try {
      final newPost = await _apiService.createPost(title: title, body: body);
      posts.insert(0, newPost);
      titleController.clear();
      bodyController.clear();
      statusMessage.value = 'Upload completed (id: ${newPost.id}).';
    } catch (error) {
      statusMessage.value = 'Upload failed: $error';
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    _apiService.dispose();
    super.onClose();
  }
}
