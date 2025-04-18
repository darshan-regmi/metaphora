class User {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? profilePic;
  final String? bio;
  final DateTime? createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profilePic,
    this.bio,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      username: map['username'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      profilePic: map['profile_pic'] as String?,
      bio: map['bio'] as String?,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'profile_pic': profilePic,
      'bio': bio,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  // Create a copy of this User with the given fields replaced
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? password,
    String? profilePic,
    String? bio,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
