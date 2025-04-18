import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:metaphora/controllers/user_controller.dart';
import 'package:metaphora/controllers/poem_controller.dart';
import 'package:metaphora/controllers/comment_controller.dart';
import 'package:metaphora/controllers/like_controller.dart';
import 'package:metaphora/controllers/saved_poem_controller.dart';
import 'package:metaphora/middleware/auth_middleware.dart';
import 'package:metaphora/database/database_helper.dart';

// Main function to start the server
void main() async {
  // Initialize the database
  await DatabaseHelper.instance.initialize();
  print('Database initialized successfully');

  // Create controllers
  final userController = UserController();
  final poemController = PoemController();
  final commentController = CommentController();
  final likeController = LikeController();
  final savedPoemController = SavedPoemController();
  
  // Create auth middleware
  final authMiddleware = AuthMiddleware();

  // Create a router
  final router = Router();
  // Create a router using shelf_router

  // User routes
  router.post('/register', userController.register);
  router.post('/login', userController.login);
  
  // Protected user routes
  router.get('/profile', (Request request) async {
    final userId = request.headers['user-id']!;
    return await Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((request) => userController.getProfile(request, userId))
      .call(request);
  });
  
  router.put('/profile', (Request request) async {
    return await Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((request) => userController.updateProfile(request))
      .call(request);
  });
  
  router.get('/profile/<id>', (Request request) async {
    final id = request.params['id']!;
    return await userController.getUserById(request, id);
  });

  // Poem routes
  router.get('/poems', poemController.getAllPoems);
  router.get('/poems/<id>', (Request request) async {
    final id = request.params['id']!;
    return await poemController.getPoemById(request, id);
  });
  
  // Protected poem routes
  router.post('/poems', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler(poemController.createPoem));
  
  router.put('/poems/<id>', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => poemController.updatePoem(request, request.params['id']!)));
  
  router.delete('/poems/<id>', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => poemController.deletePoem(request, request.params['id']!)));

  // Like routes
  router.post('/poems/<id>/like', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => likeController.likePoem(request, request.params['id']!)));
  
  router.delete('/poems/<id>/like', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => likeController.unlikePoem(request, request.params['id']!)));
  
  router.get('/poems/<id>/likes', (Request request) async {
    final id = request.params['id']!;
    return await likeController.getLikesByPoemId(request, id);
  });

  // Comment routes
  router.post('/poems/<id>/comment', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => commentController.addComment(request, request.params['id']!)));
  
  router.get('/poems/<id>/comments', (Request request) async {
    final id = request.params['id']!;
    return await commentController.getCommentsByPoemId(request, id);
  });
  
  router.put('/comments/<id>', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => commentController.updateComment(request, request.params['id']!)));
  
  router.delete('/comments/<id>', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => commentController.deleteComment(request, request.params['id']!)));

  // Saved poem routes
  router.post('/poems/<id>/save', 
    Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((Request request) => savedPoemController.savePoem(request, request.params['id']!)));
  
  router.delete('/poems/<id>/save', (Request request) async {
    final id = request.params['id']!;
    return await Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((request) => savedPoemController.unsavePoem(request, id))
      .call(request);
  });
  
  router.get('/saved-poems', (Request request) async {
    return await Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((request) => savedPoemController.getSavedPoemsByUserId(request))
      .call(request);
  });
  
  router.get('/poems/<id>/saved', (Request request) async {
    final id = request.params['id']!;
    return await Pipeline()
      .addMiddleware(authMiddleware.authenticate())
      .addHandler((request) => savedPoemController.checkPoemSaved(request, id))
      .call(request);
  });

  // Create a handler pipeline
  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(_corsMiddleware())
      .addHandler(router.call);

  // Start the server
  final server = await shelf_io.serve(
    handler,
    InternetAddress.anyIPv4,
    8080,
  );

  print('Server running on http://${server.address.host}:${server.port}');
}

// CORS middleware
Middleware _corsMiddleware() {
  return createMiddleware(
    requestHandler: (Request request) {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
        });
      }
      return null;
    },
    responseHandler: (Response response) {
      return response.change(headers: {
        ...response.headers,
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
      });
    },
  );
}
