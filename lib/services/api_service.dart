import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/remote_post.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String _postsPath = '/posts';

  final http.Client _client;

  Future<List<RemotePost>> fetchPosts({int limit = 10}) async {
    final uri = Uri.parse('$_baseUrl$_postsPath');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to download posts (status: ${response.statusCode}).');
    }

    final dynamic body = jsonDecode(response.body);
    if (body is! List) {
      throw Exception('Unexpected response format.');
    }

    final posts = body
        .cast<Map<String, dynamic>>()
        .map(RemotePost.fromJson)
        .take(limit)
        .toList(growable: false);
    return posts;
  }

  Future<RemotePost> createPost({
    required String title,
    required String body,
  }) async {
    final uri = Uri.parse('$_baseUrl$_postsPath');
    final response = await _client.post(
      uri,
      headers: const {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to upload post (status: ${response.statusCode}).');
    }

    final dynamic data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Unexpected response format when uploading post.');
    }

    return RemotePost.fromJson(data);
  }

  void dispose() {
    _client.close();
  }
}
