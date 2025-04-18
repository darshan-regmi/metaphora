import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/comment.dart';
import '../repositories/comment_repository.dart';
import '../repositories/poem_repository.dart';

class CommentController {
  final CommentRepository _commentRepository = CommentRepository();
  final PoemRepository _poemRepository = PoemRepository();

  // Add a comment to a poem
  Future<Response> addComment(Request request, String id) async {
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
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['content'] == null || (data['content'] as String).isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Comment content is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Create comment
      final comment = Comment(
        userId: userId,
        poemId: poemId,
        content: data['content'],
      );
      
      final createdComment = await _commentRepository.createComment(comment);
      
      // Get updated comment count
      final commentCount = await _commentRepository.countCommentsByPoemId(poemId);
      
      return Response.ok(
        jsonEncode({
          'message': 'Comment added successfully',
          'comment': {
            'id': createdComment.id,
            'user_id': createdComment.userId,
            'poem_id': createdComment.poemId,
            'content': createdComment.content,
            'created_at': createdComment.createdAt?.toIso8601String(),
          },
          'comment_count': commentCount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to add comment: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get comments by poem ID
  Future<Response> getCommentsByPoemId(Request request, String id) async {
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
      
      // Get comments
      final comments = await _commentRepository.getCommentsByPoemId(poemId, limit: limit, offset: offset);
      
      return Response.ok(
        jsonEncode({
          'comments': comments.map((comment) => {
            'id': comment.id,
            'user_id': comment.userId,
            'poem_id': comment.poemId,
            'content': comment.content,
            'created_at': comment.createdAt?.toIso8601String(),
          }).toList(),
          'count': await _commentRepository.countCommentsByPoemId(poemId),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get comments: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Update comment
  Future<Response> updateComment(Request request, String id) async {
    try {
      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Get comment
      final comment = await _commentRepository.getCommentById(commentId);
      if (comment == null) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user is the author of the comment
      if (comment.userId != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You are not authorized to update this comment'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;
      
      // Validate required fields
      if (data['content'] == null || (data['content'] as String).isEmpty) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Comment content is required'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Update comment
      final updatedComment = comment.copyWith(
        content: data['content'],
      );
      
      await _commentRepository.updateComment(updatedComment);
      
      return Response.ok(
        jsonEncode({
          'message': 'Comment updated successfully',
          'comment': {
            'id': updatedComment.id,
            'user_id': updatedComment.userId,
            'poem_id': updatedComment.poemId,
            'content': updatedComment.content,
            'created_at': updatedComment.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to update comment: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Delete comment
  Future<Response> deleteComment(Request request, String id) async {
    try {
      final commentId = int.tryParse(id);
      if (commentId == null) {
        return Response.badRequest(
          body: jsonEncode({'error': 'Invalid comment ID'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Get comment
      final comment = await _commentRepository.getCommentById(commentId);
      if (comment == null) {
        return Response.notFound(
          jsonEncode({'error': 'Comment not found'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Check if user is the author of the comment
      if (comment.userId != userId) {
        return Response.forbidden(
          jsonEncode({'error': 'You are not authorized to delete this comment'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Delete comment
      await _commentRepository.deleteComment(commentId);
      
      // Get updated comment count
      final commentCount = await _commentRepository.countCommentsByPoemId(comment.poemId);
      
      return Response.ok(
        jsonEncode({
          'message': 'Comment deleted successfully',
          'comment_count': commentCount,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to delete comment: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
