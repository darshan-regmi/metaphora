import 'dart:io';
import 'dart:convert';

void main() async {
  print('Initializing Poetry Sharing App server...');
  
  // Create HTTP server
  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  print('Server running on http://localhost:8080');
  
  // Handle requests
  await for (final request in server) {
    try {
      await handleRequest(request);
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

// Handle HTTP requests
Future<void> handleRequest(HttpRequest request) async {
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
  
  print('Received $method request for $path');
  
  // Route requests
  if (path == '/register' && method == 'POST') {
    await handleRegister(request);
  } else if (path == '/login' && method == 'POST') {
    await handleLogin(request);
  } else if (path == '/poems' && method == 'GET') {
    await handleGetAllPoems(request);
  } else if (path.startsWith('/poems/') && method == 'GET') {
    final id = int.tryParse(path.substring('/poems/'.length));
    if (id != null) {
      await handleGetPoemById(request, id);
    } else {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..write(jsonEncode({'error': 'Invalid poem ID'}))
        ..close();
    }
  } else if (path == '/poems' && method == 'POST') {
    await handleCreatePoem(request);
  } else {
    request.response
      ..statusCode = HttpStatus.notFound
      ..write(jsonEncode({'error': 'Route not found'}))
      ..close();
  }
}

// Handle user registration
Future<void> handleRegister(HttpRequest request) async {
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
  
  // Mock successful registration
  request.response
    ..statusCode = HttpStatus.created
    ..write(jsonEncode({
      'message': 'User registered successfully',
      'user': {
        'id': 1,
        'username': data['username'],
        'email': data['email'],
      }
    }))
    ..close();
}

// Handle user login
Future<void> handleLogin(HttpRequest request) async {
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
  
  // Mock successful login
  request.response
    ..statusCode = HttpStatus.ok
    ..write(jsonEncode({
      'message': 'Login successful',
      'user': {
        'id': 1,
        'username': 'demo_user',
        'email': data['email'],
        'profile_pic': null,
        'bio': 'Poetry enthusiast',
      },
      'token': 'sample_token_1',
    }))
    ..close();
}

// Handle get all poems
Future<void> handleGetAllPoems(HttpRequest request) async {
  // Mock poems data
  final poems = [
    {
      'id': 1,
      'user_id': 1,
      'title': 'Autumn Leaves',
      'content': 'Golden leaves falling,\nDancing in the autumn breeze,\nNature\'s last hurrah.',
      'category': 'Nature',
      'created_at': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      'user': {
        'username': 'demo_user',
        'profile_pic': null,
      },
      'like_count': 5,
      'comment_count': 2,
    },
    {
      'id': 2,
      'user_id': 1,
      'title': 'Moonlight',
      'content': 'Silver beams cascading,\nIlluminating the night sky,\nMoonlight\'s gentle touch.',
      'category': 'Night',
      'created_at': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
      'user': {
        'username': 'demo_user',
        'profile_pic': null,
      },
      'like_count': 3,
      'comment_count': 1,
    },
  ];
  
  request.response
    ..statusCode = HttpStatus.ok
    ..write(jsonEncode({
      'poems': poems,
      'count': poems.length,
    }))
    ..close();
}

// Handle get poem by ID
Future<void> handleGetPoemById(HttpRequest request, int id) async {
  // Mock poem data
  final poem = {
    'id': id,
    'user_id': 1,
    'title': 'Autumn Leaves',
    'content': 'Golden leaves falling,\nDancing in the autumn breeze,\nNature\'s last hurrah.',
    'category': 'Nature',
    'created_at': DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
    'user': {
      'username': 'demo_user',
      'profile_pic': null,
    },
    'like_count': 5,
    'comment_count': 2,
  };
  
  request.response
    ..statusCode = HttpStatus.ok
    ..write(jsonEncode(poem))
    ..close();
}

// Handle create poem
Future<void> handleCreatePoem(HttpRequest request) async {
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
  
  // Mock successful poem creation
  request.response
    ..statusCode = HttpStatus.created
    ..write(jsonEncode({
      'message': 'Poem created successfully',
      'poem': {
        'id': 3,
        'user_id': data['user_id'],
        'title': data['title'],
        'content': data['content'],
        'category': data['category'],
        'created_at': DateTime.now().toIso8601String(),
      }
    }))
    ..close();
}
