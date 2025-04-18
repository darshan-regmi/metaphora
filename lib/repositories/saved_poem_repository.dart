import '../database/database_helper.dart';
import '../models/saved_poem.dart';

class SavedPoemRepository {
  final _db = DatabaseHelper.instance.database;

  // Save a poem
  Future<SavedPoem> savePoem(SavedPoem savedPoem) async {
    final id = _db.prepare('''
      INSERT INTO saved_poems (user_id, poem_id)
      VALUES (?, ?)
    ''')
    ..execute([
      savedPoem.userId,
      savedPoem.poemId,
    ])
    ..dispose();
    
    return savedPoem.copyWith(id: _db.lastInsertRowId);
  }

  // Check if a user has saved a poem
  Future<bool> hasUserSavedPoem(int userId, int poemId) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM saved_poems 
      WHERE user_id = ? AND poem_id = ?
    ''');
    
    final result = stmt.select([userId, poemId]);
    stmt.dispose();
    
    return (result.first['count'] as int) > 0;
  }

  // Get saved poem by ID
  Future<SavedPoem?> getSavedPoemById(int id) async {
    final stmt = _db.prepare('''
      SELECT * FROM saved_poems WHERE id = ?
    ''');
    
    final result = stmt.select([id]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return SavedPoem.fromMap(result.first);
  }

  // Get saved poems by user ID
  Future<List<SavedPoem>> getSavedPoemsByUserId(int userId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM saved_poems WHERE user_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([userId]);
    stmt.dispose();
    
    return result.map((row) => SavedPoem.fromMap(row)).toList();
  }

  // Get saved poems by poem ID
  Future<List<SavedPoem>> getSavedPoemsByPoemId(int poemId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM saved_poems WHERE poem_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([poemId]);
    stmt.dispose();
    
    return result.map((row) => SavedPoem.fromMap(row)).toList();
  }

  // Unsave a poem
  Future<void> unsavePoem(int userId, int poemId) async {
    final stmt = _db.prepare('''
      DELETE FROM saved_poems WHERE user_id = ? AND poem_id = ?
    ''');
    
    stmt.execute([userId, poemId]);
    stmt.dispose();
  }

  // Delete saved poem by ID
  Future<void> deleteSavedPoem(int id) async {
    final stmt = _db.prepare('''
      DELETE FROM saved_poems WHERE id = ?
    ''');
    
    stmt.execute([id]);
    stmt.dispose();
  }

  // Count saved poems for a user
  Future<int> countSavedPoemsByUserId(int userId) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM saved_poems WHERE user_id = ?
    ''');
    
    final result = stmt.select([userId]);
    stmt.dispose();
    
    return result.first['count'] as int;
  }
}
