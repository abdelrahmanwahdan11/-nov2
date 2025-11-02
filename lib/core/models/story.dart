class Story {
  const Story({
    required this.id,
    required this.userId,
    required this.isPro,
    required this.mediaUrl,
    required this.caption,
    required this.createdAt,
    required this.likes,
    this.reactions = const [],
    this.hidden = false,
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
      reactions: (json['reactions'] as List<dynamic>? ?? []).cast<String>(),
      hidden: json['hidden'] as bool? ?? false,
    );
  }

  final String id;
  final String userId;
  final bool isPro;
  final String mediaUrl;
  final String caption;
  final DateTime createdAt;
  final int likes;
  final List<String> reactions;
  final bool hidden;

  Story copyWith({
    int? likes,
    List<String>? reactions,
    bool? hidden,
  }) {
    return Story(
      id: id,
      userId: userId,
      isPro: isPro,
      mediaUrl: mediaUrl,
      caption: caption,
      createdAt: createdAt,
      likes: likes ?? this.likes,
      reactions: reactions ?? this.reactions,
      hidden: hidden ?? this.hidden,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'isPro': isPro,
        'mediaUrl': mediaUrl,
        'caption': caption,
        'createdAt': createdAt.toIso8601String(),
        'likes': likes,
        'reactions': reactions,
        'hidden': hidden,
      };
}
