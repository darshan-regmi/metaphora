import '../database/database_helper.dart';
import '../models/poem.dart';

class PoemRepository {
  final _db = DatabaseHelper.instance.database;

  // Get poem by ID with user info
  Future<Poem?> getPoemById(int id) async {
    final stmt = _db.prepare('''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.id = ?
    ''');
    
    final result = stmt.select([id]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    final row = result.first;
    return Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    );
  }

  // Create a new poem
  Future<Poem> createPoem(Poem poem) async {
    final id = _db.prepare('''
      INSERT INTO poems (user_id, title, content, category)
      VALUES (?, ?, ?, ?)
    ''')
    ..execute([
      poem.userId,
      poem.title,
      poem.content,
      poem.category,
    ])
    ..dispose();
    
    return poem.copyWith(id: _db.lastInsertRowId);
  }

  // Get all poems with user info
  Future<List<Poem>> getAllPoems({int? limit, int? offset}) async {
    String query = '''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final result = _db.select(query);
    
    return result.map((row) => Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    )).toList();
  }

  // Get poems by user ID
  Future<List<Poem>> getPoemsByUserId(int userId, {int? limit, int? offset}) async {
    String query = '''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.user_id = ?
      ORDER BY p.created_at DESC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([userId]);
    stmt.dispose();
    
    return result.map((row) => Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    )).toList();
  }

  // Get poems by category
  Future<List<Poem>> getPoemsByCategory(String category, {int? limit, int? offset}) async {
    String query = '''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.category = ?
      ORDER BY p.created_at DESC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final result = stmt.select([category]);
    stmt.dispose();
    
    return result.map((row) => Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    )).toList();
  }

  // Search poems by title or content
  Future<List<Poem>> searchPoems(String searchTerm, {int? limit, int? offset}) async {
    String query = '''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.title LIKE ? OR p.content LIKE ?
      ORDER BY p.created_at DESC
    ''';
    
    if (limit != null) {
      query += ' LIMIT $limit';
      
      if (offset != null) {
        query += ' OFFSET $offset';
      }
    }
    
    final stmt = _db.prepare(query);
    final searchPattern = '%$searchTerm%';
    final result = stmt.select([searchPattern, searchPattern]);
    stmt.dispose();
    
    return result.map((row) => Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    )).toList();
  }

  // Update poem
  Future<Poem> updatePoem(Poem poem) async {
    final stmt = _db.prepare('''
      UPDATE poems
      SET title = ?, content = ?, category = ?
      WHERE id = ?
    ''');
    
    stmt.execute([
      poem.title,
      poem.content,
      poem.category,
      poem.id,
    ]);
    stmt.dispose();
    
    return poem;
  }

  // Delete poem
  Future<void> deletePoem(int id) async {
    final stmt = _db.prepare('''
      DELETE FROM poems WHERE id = ?
    ''');
    
    stmt.execute([id]);
    stmt.dispose();
  }

  // Get next poem after the current poem
  Future<Poem?> getNextPoem(int currentPoemId) async {
    final stmt = _db.prepare('''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.id > ?
      ORDER BY p.id ASC
      LIMIT 1
    ''');
    
    final result = stmt.select([currentPoemId]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    final row = result.first;
    return Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    );
  }

  // Get previous poem before the current poem
  Future<Poem?> getPreviousPoem(int currentPoemId) async {
    final stmt = _db.prepare('''
      SELECT p.*, 
             u.username,
             (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
             (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      LEFT JOIN users u ON p.user_id = u.id
      WHERE p.id < ?
      ORDER BY p.id DESC
      LIMIT 1
    ''');
    
    final result = stmt.select([currentPoemId]);
    stmt.dispose();
    
    if (result.isEmpty) {
      return null;
    }
    
    final row = result.first;
    return Poem(
      id: row['id'] as int,
      userId: row['user_id'] as int,
      title: row['title'] as String,
      content: row['content'] as String,
      category: row['category'] as String?,
      createdAt: row['created_at'] != null 
          ? DateTime.parse(row['created_at'] as String) 
          : null,
      user: {'username': row['username']},
      likeCount: row['like_count'] as int,
      commentCount: row['comment_count'] as int,
    );
  }
}
