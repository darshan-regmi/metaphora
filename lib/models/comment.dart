class Comment {
  final int? id;
  final int userId;
  final int poemId;
  final String content;
  final DateTime? createdAt;

  Comment({
    this.id,
    required this.userId,
    required this.poemId,
    required this.content,
    this.createdAt,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      poemId: map['poem_id'] as int,
      content: map['content'] as String,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'poem_id': poemId,
      'content': content,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create a copy of this Comment with the given fields replaced
  Comment copyWith({
    int? id,
    int? userId,
    int? poemId,
    String? content,
    DateTime? createdAt,
  }) {
    return Comment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      poemId: poemId ?? this.poemId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
