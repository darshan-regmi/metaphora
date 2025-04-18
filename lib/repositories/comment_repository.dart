import '../database/database_helper.dart';
import '../models/comment.dart';

class CommentRepository {
  final _db = DatabaseHelper.instance.database;

  // Create a new comment
  Future<Comment> createComment(Comment comment) async {
    final id = _db.prepare('''
      INSERT INTO comments (user_id, poem_id, content)
      VALUES (?, ?, ?)
    ''')
    ..execute([
      comment.userId,
      comment.poemId,
      comment.content,
    ])
    ..dispose();
    
    return comment.copyWith(id: _db.lastInsertRowId);
  }

  // Get comment by ID
  Future<Comment?> getCommentById(int id) async {
    final stmt = _db.prepare('''
      SELECT * FROM comments WHERE id = ?
    ''');
    
    final result = stmt.select([id]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    return Comment.fromMap(result.first);
  }

  // Get comments by poem ID
  Future<List<Comment>> getCommentsByPoemId(int poemId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM comments WHERE poem_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([poemId]);
    stmt.dispose();
    
    return result.map((row) => Comment.fromMap(row)).toList();
  }

  // Get comments by user ID
  Future<List<Comment>> getCommentsByUserId(int userId, {int? limit, int? offset}) async {
    String query = 'SELECT * FROM comments WHERE user_id = ? ORDER BY created_at DESC';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([userId]);
    stmt.dispose();
    
    return result.map((row) => Comment.fromMap(row)).toList();
  }

  // Update comment
  Future<Comment> updateComment(Comment comment) async {
    final stmt = _db.prepare('''
      UPDATE comments
      SET content = ?
      WHERE id = ?
    ''');
    
    stmt.execute([
      comment.content,
      comment.id,
    ]);
    stmt.dispose();
    
    return comment;
  }

  // Delete comment
  Future<void> deleteComment(int id) async {
    final stmt = _db.prepare('''
      DELETE FROM comments WHERE id = ?
    ''');
    
    stmt.execute([id]);
    stmt.dispose();
  }

  // Count comments for a poem
  Future<int> countCommentsByPoemId(int poemId) async {
    final stmt = _db.prepare('''
      SELECT COUNT(*) as count FROM comments WHERE poem_id = ?
    ''');
    
    final result = stmt.select([poemId]);
    stmt.dispose();
    
    return result.first['count'] as int;
  }
}
