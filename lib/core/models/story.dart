class Story {
  const Story({
    required this.id,
    required this.userId,
    required this.isPro,
    required this.mediaUrl,
    required this.caption,
    required this.createdAt,
    required this.likes,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      userId: json['userId'] as String,
      isPro: json['isPro'] as bool,
      mediaUrl: json['mediaUrl'] as String,
      caption: json['caption'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      likes: json['likes'] as int,
    );
  }

  final String id;
  final String userId;
  final bool isPro;
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;
  final int likes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'isPro': isPro,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
      };
}
