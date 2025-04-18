import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/like.dart';
import '../repositories/like_repository.dart';
import '../repositories/poem_repository.dart';

class LikeController {
  final LikeRepository _likeRepository = LikeRepository();
  final PoemRepository _poemRepository = PoemRepository();

  // Like a poem
  Future<Response> likePoem(Request request, String id) async {
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
      
      // Check if poem exists
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user has already liked the poem
      final hasLiked = await _likeRepository.hasUserLikedPoem(userId, poemId);
      if (hasLiked) {
        return Response.badRequest(
          body: jsonEncode({'error': 'You have already liked this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Create like
      final like = Like(
        userId: userId,
        poemId: poemId,
      );
      
      final createdLike = await _likeRepository.createLike(like);
      
      // Get updated like count
      final likeCount = await _likeRepository.countLikesByPoemId(poemId);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem liked successfully',
          'like': {
            'id': createdLike.id,
            'user_id': createdLike.userId,
            'poem_id': createdLike.poemId,
            'created_at': createdLike.createdAt?.toIso8601String(),
          },
          'like_count': likeCount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to like poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Unlike a poem
  Future<Response> unlikePoem(Request request, String id) async {
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
      
      // Check if poem exists
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user has liked the poem
      final hasLiked = await _likeRepository.hasUserLikedPoem(userId, poemId);
      if (!hasLiked) {
        return Response.badRequest(
          body: jsonEncode({'error': 'You have not liked this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Unlike poem
      await _likeRepository.unlikePoem(userId, poemId);
      
      // Get updated like count
      final likeCount = await _likeRepository.countLikesByPoemId(poemId);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem unliked successfully',
          'like_count': likeCount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to unlike poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get likes by poem ID
  Future<Response> getLikesByPoemId(Request request, String id) async {
    try {
      final poemId = int.tryParse(id);
      if (poemId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid poem ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if poem exists
      final poem = await _poemRepository.getPoemById(poemId);
      if (poem == null) {
        return Response.notFound(
          jsonEncode({'error': 'Poem not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get likes
      final likes = await _likeRepository.getLikesByPoemId(poemId, limit: limit, offset: offset);
      
      return Response.ok(
        jsonEncode({
          'likes': likes.map((like) => {
            'id': like.id,
            'user_id': like.userId,
            'poem_id': like.poemId,
            'created_at': like.createdAt?.toIso8601String(),
          }).toList(),
          'count': await _likeRepository.countLikesByPoemId(poemId),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get likes: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get likes by user ID
  Future<Response> getLikesByUserId(Request request, String id) async {
    try {
      final userId = int.tryParse(id);
      if (userId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid user ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get likes
      final likes = await _likeRepository.getLikesByUserId(userId, limit: limit, offset: offset);
      
      return Response.ok(
        jsonEncode({
          'likes': likes.map((like) => {
            'id': like.id,
            'user_id': like.userId,
            'poem_id': like.poemId,
            'created_at': like.createdAt?.toIso8601String(),
          }).toList(),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get likes: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
