import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/poem.dart';
import '../repositories/poem_repository.dart';
import '../repositories/like_repository.dart';
import '../repositories/comment_repository.dart';

class PoemController {
  final PoemRepository _poemRepository = PoemRepository();
  final LikeRepository _likeRepository = LikeRepository();
  final CommentRepository _commentRepository = CommentRepository();

  // Create a new poem
  Future<Response> createPoem(Request request) async {
    try {
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['title'] == null || data['content'] == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Title and content are required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Create poem
      final poem = Poem(
        userId: userId,
        title: data['title'],
        content: data['content'],
        category: data['category'],
      );
      
      final createdPoem = await _poemRepository.createPoem(poem);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem created successfully',
          'poem': {
            'id': createdPoem.id,
            'user_id': createdPoem.userId,
            'title': createdPoem.title,
            'content': createdPoem.content,
            'category': createdPoem.category,
            'created_at': createdPoem.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to create poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get all poems
  Future<Response> getAllPoems(Request request) async {
    try {
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get poems
      final poems = await _poemRepository.getAllPoems(limit: limit, offset: offset);
      
      // Get like and comment counts for each poem
      final poemsWithCounts = await Future.wait(poems.map((poem) async {
        final likeCount = await _likeRepository.countLikesByPoemId(poem.id!);
        final commentCount = await _commentRepository.countCommentsByPoemId(poem.id!);
        
        return {
          'id': poem.id,
          'user_id': poem.userId,
          'title': poem.title,
          'content': poem.content,
          'category': poem.category,
          'created_at': poem.createdAt?.toIso8601String(),
          'like_count': likeCount,
          'comment_count': commentCount,
        };
      }));
      
      return Response.ok(
        jsonEncode({'poems': poemsWithCounts}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get poems: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get poem by ID
  Future<Response> getPoemById(Request request, String id) async {
    try {
      final poemId = int.tryParse(id);
      if (poemId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid poem ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get like and comment counts
      final likeCount = await _likeRepository.countLikesByPoemId(poemId);
      final commentCount = await _commentRepository.countCommentsByPoemId(poemId);
      
      // Check if user has liked the poem (if authenticated)
      bool userHasLiked = false;
      if (request.context.containsKey('userId')) {
        final userId = request.context['userId'] as int;
        userHasLiked = await _likeRepository.hasUserLikedPoem(userId, poemId);
      }
      
      return Response.ok(
        jsonEncode({
          'poem': {
            'id': poem.id,
            'user_id': poem.userId,
            'title': poem.title,
            'content': poem.content,
            'category': poem.category,
            'created_at': poem.createdAt?.toIso8601String(),
            'like_count': likeCount,
            'comment_count': commentCount,
            'user_has_liked': userHasLiked,
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get previous poem
  Future<Poem?> getPreviousPoem(int? currentPoemId) async {
    if (currentPoemId == null) return null;
    try {
      final poems = await _poemRepository.getAllPoems();
    if (poems.isEmpty) return null;
    
    final currentIndex = poems.indexWhere((poem) => poem.id == currentPoemId);
    if (currentIndex <= 0) return null;
    
    return poems[currentIndex - 1];
    } catch (e) {
      print('Error getting previous poem: $e');
      return null;
    }
  }

  // Get next poem
  Future<Poem?> getNextPoem(int? currentPoemId) async {
    if (currentPoemId == null) return null;
    try {
      final poems = await _poemRepository.getAllPoems();
    if (poems.isEmpty) return null;
    
    final currentIndex = poems.indexWhere((poem) => poem.id == currentPoemId);
    if (currentIndex == -1 || currentIndex >= poems.length - 1) return null;
    
    return poems[currentIndex + 1];
    } catch (e) {
      print('Error getting next poem: $e');
      return null;
    }
  }

  // Get poems by user ID
  Future<Response> getPoemsByUserId(Request request, String userId) async {
    try {
      final userIdInt = int.tryParse(userId);
      if (userIdInt == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get poems
      final poems = await _poemRepository.getPoemsByUserId(userIdInt, limit: limit, offset: offset);
      
      // Get like and comment counts for each poem
      final poemsWithCounts = await Future.wait(poems.map((poem) async {
        final likeCount = await _likeRepository.countLikesByPoemId(poem.id!);
        final commentCount = await _commentRepository.countCommentsByPoemId(poem.id!);
        
        return {
          'id': poem.id,
          'user_id': poem.userId,
          'title': poem.title,
          'content': poem.content,
          'category': poem.category,
          'created_at': poem.createdAt?.toIso8601String(),
          'like_count': likeCount,
          'comment_count': commentCount,
        };
      }));
      
      return Response.ok(
        jsonEncode({'poems': poemsWithCounts}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get poems: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get poems by category
  Future<Response> getPoemsByCategory(Request request, String category) async {
    try {
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get poems
      final poems = await _poemRepository.getPoemsByCategory(category, limit: limit, offset: offset);
      
      // Get like and comment counts for each poem
      final poemsWithCounts = await Future.wait(poems.map((poem) async {
        final likeCount = await _likeRepository.countLikesByPoemId(poem.id!);
        final commentCount = await _commentRepository.countCommentsByPoemId(poem.id!);
        
        return {
          'id': poem.id,
          'user_id': poem.userId,
          'title': poem.title,
          'content': poem.content,
          'category': poem.category,
          'created_at': poem.createdAt?.toIso8601String(),
          'like_count': likeCount,
          'comment_count': commentCount,
        };
      }));
      
      return Response.ok(
        jsonEncode({'poems': poemsWithCounts}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get poems: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Search poems
  Future<Response> searchPoems(Request request) async {
    try {
      // Get search term from query parameters
      final searchTerm = request.url.queryParameters['q'];
      if (searchTerm == null || searchTerm.isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Search term is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Parse query parameters for pagination
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10');
      final offset = int.tryParse(request.url.queryParameters['offset'] ?? '0');
      
      // Search poems
      final poems = await _poemRepository.searchPoems(searchTerm, limit: limit, offset: offset);
      
      // Get like and comment counts for each poem
      final poemsWithCounts = await Future.wait(poems.map((poem) async {
        final likeCount = await _likeRepository.countLikesByPoemId(poem.id!);
        final commentCount = await _commentRepository.countCommentsByPoemId(poem.id!);
        
        return {
          'id': poem.id,
          'user_id': poem.userId,
          'title': poem.title,
          'content': poem.content,
          'category': poem.category,
          'created_at': poem.createdAt?.toIso8601String(),
          'like_count': likeCount,
          'comment_count': commentCount,
        };
      }));
      
      return Response.ok(
        jsonEncode({'poems': poemsWithCounts}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to search poems: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Update poem
  Future<Response> updatePoem(Request request, String id) async {
    try {
      final poemId = int.tryParse(id);
      if (poemId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid poem ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Get poem
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user is the author
      if (poem.userId != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You are not authorized to update this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Update poem
      final updatedPoem = poem.copyWith(
        title: data['title'] ?? poem.title,
        content: data['content'] ?? poem.content,
        category: data['category'] ?? poem.category,
      );
      
      await _poemRepository.updatePoem(updatedPoem);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem updated successfully',
          'poem': {
            'id': updatedPoem.id,
            'user_id': updatedPoem.userId,
            'title': updatedPoem.title,
            'content': updatedPoem.content,
            'category': updatedPoem.category,
            'created_at': updatedPoem.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Delete poem
  Future<Response> deletePoem(Request request, String id) async {
    try {
      final poemId = int.tryParse(id);
      if (poemId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid poem ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Get poem
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user is the author
      if (poem.userId != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You are not authorized to delete this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Delete poem
      await _poemRepository.deletePoem(poemId);
      
      return Response.ok(
        jsonEncode({'message': 'Poem deleted successfully'}),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
