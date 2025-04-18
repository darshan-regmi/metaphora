import '../database/database_helper.dart';
import '../models/like.dart';

class LikeRepository {
  final _db = DatabaseHelper.instance.database;

  // Create a new like
  Future<Like> createLike(Like like) async {
    final id = _db.prepare('''
      INSERT INTO likes (user_id, poem_id)
      VALUES (?, ?)
    ''')
    ..execute([
      like.userId,
      like.poemId,
    ])
    ..dispose();
    
    return like.copyWith(id: _db.lastInsertRowId);
  }

  // Check if a user has liked a poem
  Future<bool> hasUserLikedPoem(int userId, int poemId) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM likes 
      WHERE user_id = ? AND poem_id = ?
    ''');
    
    final result = stmt.select([userId, poemId]);
    stmt.dispose();
    
    return (result.first['count'] as int) > 0;
  }

  // Get like by ID
  Future<Like?> getLikeById(int id) async {
    final stmt = _db.prepare('''
      SELECT * FROM likes WHERE id = ?
    ''');
    
    final result = stmt.select([id]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return Like.fromMap(result.first);
  }

  // Get likes by poem ID
  Future<List<Like>> getLikesByPoemId(int poemId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM likes WHERE poem_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([poemId]);
    stmt.dispose();
    
    return result.map((row) => Like.fromMap(row)).toList();
  }

  // Get likes by user ID
  Future<List<Like>> getLikesByUserId(int userId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM likes WHERE user_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([userId]);
    stmt.dispose();
    
    return result.map((row) => Like.fromMap(row)).toList();
  }

  // Delete like (unlike)
  Future<void> deleteLike(int id) async {
    final stmt = _db.prepare('''
      DELETE FROM likes WHERE id = ?
    ''');
    
    stmt.execute([id]);
    stmt.dispose();
  }

  // Unlike a poem by user ID and poem ID
  Future<void> unlikePoem(int userId, int poemId) async {
    final stmt = _db.prepare('''
      DELETE FROM likes WHERE user_id = ? AND poem_id = ?
    ''');
    
    stmt.execute([userId, poemId]);
    stmt.dispose();
  }

  // Count likes for a poem
  Future<int> countLikesByPoemId(int poemId) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM likes WHERE poem_id = ?
    ''');
    
    final result = stmt.select([poemId]);
    stmt.dispose();
    
    return result.first['count'] as int;
  }
}
