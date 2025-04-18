import 'dart:io';
import 'dart:convert';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

// Simple HTTP server implementation
void main() async {
  // Initialize database
  final db = await initializeDatabase();
  print('Database initialized');
  
  // Create HTTP server
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on http://localhost:8080');
  
  // Handle requests
  await for (final request in server) {
    try {
      await handleRequest(request, db);
    } catch (e) {
      print('Error handling request: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'error': 'Internal server error'}))
        ..close();
    }
  }
}

// Initialize SQLite database
Future<sqlite3.Database> initializeDatabase() async {
  final String path = 'poetry_app.db';
  
  final db = sqlite3.sqlite3.open(path);
  
  // Create tables
  db.execute('''
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
  
  db.execute('''
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
  
  db.execute('''
    CREATE TABLE IF NOT EXISTS likes (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      poem_id INTEGER NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
    )
  ''');
  
  db.execute('''
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
  
  db.execute('''
    CREATE TABLE IF NOT EXISTS saved_poems (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      poem_id INTEGER NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (poem_id) REFERENCES poems(id) ON DELETE CASCADE
    )
  ''');
  
  return db;
}

// Handle HTTP requests
Future<void> handleRequest(HttpRequest request, sqlite3.Database db) async {
  // Add CORS headers
  request.response.headers.add('Access-Control-Allow-Origin', '*');
  request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  request.response.headers.add('Access-Control-Allow-Headers', 'Origin, Content-Type, Accept, Authorization');
  
  // Handle preflight requests
  if (request.method == 'OPTIONS') {
    request.response
      ..statusCode = HttpStatus.ok
      ..close();
    return;
  }
  
  // Set content type
  request.response.headers.contentType = ContentType.json;
  
  // Parse path and method
  final path = request.uri.path;
  final method = request.method;
  
  // Route requests
  if (path == '/register' && method == 'POST') {
    await handleRegister(request, db);
  } else if (path == '/login' && method == 'POST') {
    await handleLogin(request, db);
  } else if (path == '/poems' && method == 'GET') {
    await handleGetAllPoems(request, db);
  } else if (path.startsWith('/poems/') && method == 'GET') {
    final id = int.tryParse(path.substring('/poems/'.length));
    if (id != null) {
      await handleGetPoemById(request, db, id);
    } else {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(jsonEncode({'error': 'Invalid poem ID'}))
        ..close();
    }
  } else if (path == '/poems' && method == 'POST') {
    await handleCreatePoem(request, db);
  } else {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write(jsonEncode({'error': 'Route not found'}))
      ..close();
  }
}

// Handle user registration
Future<void> handleRegister(HttpRequest request, sqlite3.Database db) async {
  final body = await utf8.decoder.bind(request).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  
  // Validate required fields
  if (data['username'] == null || data['email'] == null || data['password'] == null) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write(jsonEncode({'error': 'Username, email, and password are required'}))
      ..close();
    return;
  }
  
  try {
    // Check if username or email already exists
    final result = db.select(
      'SELECT * FROM users WHERE username = ? OR email = ?',
      [data['username'], data['email']]
    );
    
    if (result.isNotEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(jsonEncode({'error': 'Username or email already exists'}))
        ..close();
      return;
    }
    
    // Insert new user
    final stmt = db.prepare('''
      INSERT INTO users (username, email, password)
      VALUES (?, ?, ?)
    ''');
    
    stmt.execute([
      data['username'],
      data['email'],
      data['password'], // In production, hash the password
    ]);
    
    stmt.dispose();
    
    request.response
      ..statusCode = HttpStatus.created
      ..write(jsonEncode({
        'message': 'User registered successfully',
        'user': {
          'username': data['username'],
          'email': data['email'],
        }
      }))
      ..close();
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to register user: ${e.toString()}'}))
      ..close();
  }
}

// Handle user login
Future<void> handleLogin(HttpRequest request, sqlite3.Database db) async {
  final body = await utf8.decoder.bind(request).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  
  // Validate required fields
  if (data['email'] == null || data['password'] == null) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write(jsonEncode({'error': 'Email and password are required'}))
      ..close();
    return;
  }
  
  try {
    // Find user by email and password
    final result = db.select(
      'SELECT * FROM users WHERE email = ? AND password = ?',
      [data['email'], data['password']]
    );
    
    if (result.isEmpty) {
      request.response
        ..statusCode = HttpStatus.unauthorized
        ..write(jsonEncode({'error': 'Invalid email or password'}))
        ..close();
      return;
    }
    
    final user = result.first;
    
    // In a real app, generate a JWT token here
    final token = 'sample_token_${user['id']}';
    
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode({
        'message': 'Login successful',
        'user': {
          'id': user['id'],
          'username': user['username'],
          'email': user['email'],
          'profile_pic': user['profile_pic'],
          'bio': user['bio'],
        },
        'token': token,
      }))
      ..close();
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to login: ${e.toString()}'}))
      ..close();
  }
}

// Handle get all poems
Future<void> handleGetAllPoems(HttpRequest request, sqlite3.Database db) async {
  try {
    // Get query parameters for pagination
    final limit = int.tryParse(request.uri.queryParameters['limit'] ?? '10');
    final offset = int.tryParse(request.uri.queryParameters['offset'] ?? '0');
    
    // Get poems with user info
    final result = db.select('''
      SELECT p.*, u.username, u.profile_pic,
        (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      JOIN users u ON p.user_id = u.id
      ORDER BY p.created_at DESC
      LIMIT ? OFFSET ?
    ''', [limit, offset]);
    
    final poems = result.map((row) => {
      'id': row['id'],
      'user_id': row['user_id'],
      'title': row['title'],
      'content': row['content'],
      'category': row['category'],
      'created_at': row['created_at'],
      'user': {
        'username': row['username'],
        'profile_pic': row['profile_pic'],
      },
      'like_count': row['like_count'],
      'comment_count': row['comment_count'],
    }).toList();
    
    // Get total count
    final countResult = db.select('SELECT COUNT(*) as count FROM poems');
    final totalCount = countResult.first['count'] as int;
    
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode({
        'poems': poems,
        'count': totalCount,
      }))
      ..close();
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to get poems: ${e.toString()}'}))
      ..close();
  }
}

// Handle get poem by ID
Future<void> handleGetPoemById(HttpRequest request, sqlite3.Database db, int id) async {
  try {
    // Get poem with user info
    final result = db.select('''
      SELECT p.*, u.username, u.profile_pic,
        (SELECT COUNT(*) FROM likes WHERE poem_id = p.id) as like_count,
        (SELECT COUNT(*) FROM comments WHERE poem_id = p.id) as comment_count
      FROM poems p
      JOIN users u ON p.user_id = u.id
      WHERE p.id = ?
    ''', [id]);
    
    if (result.isEmpty) {
      request.response
        ..statusCode = HttpStatus.notFound
        ..write(jsonEncode({'error': 'Poem not found'}))
        ..close();
      return;
    }
    
    final row = result.first;
    
    final poem = {
      'id': row['id'],
      'user_id': row['user_id'],
      'title': row['title'],
      'content': row['content'],
      'category': row['category'],
      'created_at': row['created_at'],
      'user': {
        'username': row['username'],
        'profile_pic': row['profile_pic'],
      },
      'like_count': row['like_count'],
      'comment_count': row['comment_count'],
    };
    
    request.response
      ..statusCode = HttpStatus.ok
      ..write(jsonEncode(poem))
      ..close();
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to get poem: ${e.toString()}'}))
      ..close();
  }
}

// Handle create poem
Future<void> handleCreatePoem(HttpRequest request, sqlite3.Database db) async {
  // In a real app, get user ID from token
  // For now, we'll assume user ID is provided in the request
  
  final body = await utf8.decoder.bind(request).join();
  final data = jsonDecode(body) as Map<String, dynamic>;
  
  // Validate required fields
  if (data['user_id'] == null || data['title'] == null || data['content'] == null) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..write(jsonEncode({'error': 'User ID, title, and content are required'}))
      ..close();
    return;
  }
  
  try {
    // Insert new poem
    final stmt = db.prepare('''
      INSERT INTO poems (user_id, title, content, category)
      VALUES (?, ?, ?, ?)
    ''');
    
    stmt.execute([
      data['user_id'],
      data['title'],
      data['content'],
      data['category'],
    ]);
    
    final id = db.lastInsertRowId;
    stmt.dispose();
    
    // Get the created poem
    final result = db.select('SELECT * FROM poems WHERE id = ?', [id]);
    final poem = result.first;
    
    request.response
      ..statusCode = HttpStatus.created
      ..write(jsonEncode({
        'message': 'Poem created successfully',
        'poem': {
          'id': poem['id'],
          'user_id': poem['user_id'],
          'title': poem['title'],
          'content': poem['content'],
          'category': poem['category'],
          'created_at': poem['created_at'],
        }
      }))
      ..close();
  } catch (e) {
    request.response
      ..statusCode = HttpStatus.internalServerError
      ..write(jsonEncode({'error': 'Failed to create poem: ${e.toString()}'}))
      ..close();
  }
}
