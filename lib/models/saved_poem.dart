class SavedPoem {
  final int? id;
  final int userId;
  final int poemId;
  final DateTime? createdAt;

  SavedPoem({
    this.id,
    required this.userId,
    required this.poemId,
    this.createdAt,
  });

  factory SavedPoem.fromMap(Map<String, dynamic> map) {
    return SavedPoem(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      poemId: map['poem_id'] as int,
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
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create a copy of this SavedPoem with the given fields replaced
  SavedPoem copyWith({
    int? id,
    int? userId,
    int? poemId,
    DateTime? createdAt,
  }) {
    return SavedPoem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      poemId: poemId ?? this.poemId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
