class RemotePost {
  const RemotePost({
    required this.id,
    required this.title,
    required this.body,
  });

  final int id;
  final String title;
  final String body;

  factory RemotePost.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'];
    return RemotePost(
      id: idValue is int ? idValue : int.tryParse('$idValue') ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      body: (json['body'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'body': body,
      };
}
