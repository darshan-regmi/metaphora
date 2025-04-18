import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final _db = DatabaseHelper.instance.database;

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create a new user
  Future<User> createUser(User user) async {
    final hashedPassword = _hashPassword(user.password);
    final userWithHashedPassword = user.copyWith(password: hashedPassword);
    
    final id = _db.prepare('''
      INSERT INTO users (username, email, password, profile_pic, bio)
      VALUES (?, ?, ?, ?, ?)
    ''')
    ..execute([
      userWithHashedPassword.username,
      userWithHashedPassword.email,
      userWithHashedPassword.password,
      userWithHashedPassword.profilePic,
      userWithHashedPassword.bio,
    ])
    ..dispose();
    
    return userWithHashedPassword.copyWith(id: _db.lastInsertRowId);
  }

  // Get user by ID
  Future<User?> getUserById(int id) async {
    final stmt = _db.prepare('''
      SELECT * FROM users WHERE id = ?
    ''');
    
    final result = stmt.select([id]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return User.fromMap(result.first);
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final stmt = _db.prepare('''
      SELECT * FROM users WHERE email = ?
    ''');
    
    final result = stmt.select([email]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return User.fromMap(result.first);
  }

  // Get user by username
  Future<User?> getUserByUsername(String username) async {
    final stmt = _db.prepare('''
      SELECT * FROM users WHERE username = ?
    ''');
    
    final result = stmt.select([username]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return User.fromMap(result.first);
  }

  // Update user
  Future<User> updateUser(User user) async {
    final stmt = _db.prepare('''
      UPDATE users
      SET username = ?, email = ?, profile_pic = ?, bio = ?
      WHERE id = ?
    ''');
    
    stmt.execute([
      user.username,
      user.email,
      user.profilePic,
      user.bio,
      user.id,
    ]);
    stmt.dispose();
    
    return user;
  }

  // Update password
  Future<void> updatePassword(int userId, String newPassword) async {
    final hashedPassword = _hashPassword(newPassword);
    
    final stmt = _db.prepare('''
      UPDATE users
      SET password = ?
      WHERE id = ?
    ''');
    
    stmt.execute([hashedPassword, userId]);
    stmt.dispose();
  }

  // Authenticate user
  Future<User?> authenticateUser(String email, String password) async {
    final hashedPassword = _hashPassword(password);
    
    final stmt = _db.prepare('''
      SELECT * FROM users WHERE email = ? AND password = ?
    ''');
    
    final result = stmt.select([email, hashedPassword]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return User.fromMap(result.first);
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    final stmt = _db.prepare('''
      DELETE FROM users WHERE id = ?
    ''');
    
    stmt.execute([id]);
    stmt.dispose();
  }
}
