class Poem {
  final int? id;
  final int userId;
  final String title;
  final String content;
  final String? category;
  final DateTime? createdAt;
  final Map<String, dynamic>? user;
  final int likeCount;
  final int commentCount;
  final bool? isLiked;

  Poem({
    this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category,
    this.createdAt,
    this.user,
    this.likeCount = 0,
    this.commentCount = 0,
    this.isLiked,
  });

  factory Poem.fromMap(Map<String, dynamic> map) {
    return Poem(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
      user: map['user'] != null ? Map<String, dynamic>.from(map['user']) : null,
      likeCount: map['like_count'] as int? ?? 0,
      commentCount: map['comment_count'] as int? ?? 0,
      isLiked: map['is_liked'] as bool?,
    );
  }

  factory Poem.fromJson(Map<String, dynamic> json) => Poem.fromMap(json);

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt?.toIso8601String(),
      'is_liked': isLiked,
      'user': user,
      'like_count': likeCount,
      'comment_count': commentCount,
    };
  }

  // Create a copy of this Poem with the given fields replaced
  Poem copyWith({
    int? id,
    int? userId,
    String? title,
    String? content,
    String? category,
    DateTime? createdAt,
    Map<String, dynamic>? user,
    int? likeCount,
    int? commentCount,
  }) {
    return Poem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }
}
