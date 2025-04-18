import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  
  late Database _database;
  Database get database => _database;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  DatabaseHelper._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final Directory documentsDirectory = await getApplicationDocumentsDirectory();
      final String path = join(documentsDirectory.path, 'poetry_app.db');
      
      _database = sqlite3.open(path);
      
      await _createTables();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _createTables() async {
    // Users Table
    _database.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        profile_pic TEXT,
        bio TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Poems Table
    _database.execute('''
      CREATE TABLE IF NOT EXISTS poems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // Likes Table
    _database.execute('''
      CREATE TABLE IF NOT EXISTS likes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        poem_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
      )
    ''');

    // Comments Table
    _database.execute('''
      CREATE TABLE IF NOT EXISTS comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        poem_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
      )
    ''');

    // Saved Poems Table
    _database.execute('''
      CREATE TABLE IF NOT EXISTS saved_poems (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        poem_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
      )
    ''');
    
    // Add some sample data for testing
    await _addSampleData();
  }
  
  Future<void> _addSampleData() async {
    // Check if we already have users
    final userCount = _database.select('SELECT COUNT(*) as count FROM users').first['count'] as int;
    if (userCount > 0) return; // Don't add sample data if we already have users
    
    // Add sample users
    _database.execute('''
      INSERT INTO users (username, email, password, bio)
      VALUES 
        ('poetryLover', 'poetry@example.com', 'password123', 'I love writing haikus'),
        ('nightWriter', 'night@example.com', 'password123', 'Writing under the moonlight'),
        ('seaLover', 'sea@example.com', 'password123', 'Inspired by the ocean'),
        ('mountainClimber', 'mountain@example.com', 'password123', 'Finding poetry at high altitudes')
    ''');
    
    // Add sample poems
    _database.execute('''
      INSERT INTO poems (user_id, title, content, category)
      VALUES 
        (1, 'Autumn Leaves', 'Golden leaves falling,\nDancing in the autumn breeze,\nNature''s last hurrah.', 'Nature'),
        (2, 'Moonlight', 'Silver beams cascading,\nIlluminating the night sky,\nMoonlight''s gentle touch.', 'Night'),
        (3, 'Ocean Whispers', 'Waves crash on the shore,\nWhispering ancient secrets,\nEndless blue expanse.\n\nSalt spray in the air,\nSeagulls soaring overhead,\nPeace found by the sea.', 'Nature'),
        (1, 'City Lights', 'Neon signs flicker,\nHumming with electric life,\nCity never sleeps.', 'Urban'),
        (4, 'Mountain Peak', 'Standing tall and proud,\nReaching for the azure sky,\nMountain peak divine.', 'Nature'),
        (2, 'Love''s Embrace', 'Hearts beating as one,\nWarm embrace of tender love,\nSouls intertwined deep.\n\nTime stands still for us,\nIn this moment of pure bliss,\nLove''s sweet symphony.', 'Love')
    ''');
    
    // Add sample likes
    _database.execute('''
      INSERT INTO likes (user_id, poem_id)
      VALUES 
        (1, 2), (1, 3), (1, 5),
        (2, 1), (2, 3), (2, 4),
        (3, 1), (3, 2), (3, 6),
        (4, 1), (4, 6)
    ''');
    
    // Add sample comments
    _database.execute('''
      INSERT INTO comments (user_id, poem_id, content)
      VALUES 
        (2, 1, 'Beautiful imagery!'),
        (3, 1, 'I can feel the autumn breeze.'),
        (1, 2, 'This reminds me of nights at the lake.'),
        (4, 3, 'The ocean is my favorite place too.')
    ''');
  }

  Future<void> close() async {
    _database.dispose();
    _isInitialized = false;
  }
}
