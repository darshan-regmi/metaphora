import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/saved_poem.dart';
import '../repositories/saved_poem_repository.dart';
import '../repositories/poem_repository.dart';

class SavedPoemController {
  final SavedPoemRepository _savedPoemRepository = SavedPoemRepository();
  final PoemRepository _poemRepository = PoemRepository();

  // Save a poem
  Future<Response> savePoem(Request request, String id) async {
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
      
      // Check if user has already saved the poem
      final hasSaved = await _savedPoemRepository.hasUserSavedPoem(userId, poemId);
      if (hasSaved) {
        return Response.badRequest(
          body: jsonEncode({'error': 'You have already saved this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Save poem
      final savedPoem = SavedPoem(
        userId: userId,
        poemId: poemId,
      );
      
      final createdSavedPoem = await _savedPoemRepository.savePoem(savedPoem);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem saved successfully',
          'saved_poem': {
            'id': createdSavedPoem.id,
            'user_id': createdSavedPoem.userId,
            'poem_id': createdSavedPoem.poemId,
            'created_at': createdSavedPoem.createdAt?.toIso8601String(),
          },
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to save poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Unsave a poem
  Future<Response> unsavePoem(Request request, String id) async {
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
      
      // Check if user has saved the poem
      final hasSaved = await _savedPoemRepository.hasUserSavedPoem(userId, poemId);
      if (!hasSaved) {
        return Response.badRequest(
          body: jsonEncode({'error': 'You have not saved this poem'}),
          headers: {'content-type': 'application/json'},
        );
      }
      
      // Unsave poem
      await _savedPoemRepository.unsavePoem(userId, poemId);
      
      return Response.ok(
        jsonEncode({
          'message': 'Poem unsaved successfully',
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to unsave poem: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Get saved poems by user ID
  Future<Response> getSavedPoemsByUserId(Request request) async {
    try {
      // Get user ID from request context (set by auth middleware)
      final userId = request.context['userId'] as int;
      
      // Parse query parameters for pagination
      final params = request.url.queryParameters;
      final limit = int.tryParse(params['limit'] ?? '10');
      final offset = int.tryParse(params['offset'] ?? '0');
      
      // Get saved poems
      final savedPoems = await _savedPoemRepository.getSavedPoemsByUserId(userId, limit: limit, offset: offset);
      
      // Get poem details for each saved poem
      final poemsWithDetails = await Future.wait(savedPoems.map((savedPoem) async {
        final poem = await _poemRepository.getPoemById(savedPoem.poemId);
        
        return {
          'id': savedPoem.id,
          'user_id': savedPoem.userId,
          'poem_id': savedPoem.poemId,
          'created_at': savedPoem.createdAt?.toIso8601String(),
          'poem': poem != null ? {
            'id': poem.id,
            'user_id': poem.userId,
            'title': poem.title,
            'content': poem.content,
            'category': poem.category,
            'created_at': poem.createdAt?.toIso8601String(),
          } : null,
        };
      }));
      
      return Response.ok(
        jsonEncode({
          'saved_poems': poemsWithDetails,
          'count': await _savedPoemRepository.countSavedPoemsByUserId(userId),
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to get saved poems: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }

  // Check if a poem is saved by the user
  Future<Response> checkPoemSaved(Request request, String id) async {
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
      
      // Check if user has saved the poem
      final hasSaved = await _savedPoemRepository.hasUserSavedPoem(userId, poemId);
      
      return Response.ok(
        jsonEncode({
          'is_saved': hasSaved,
        }),
        headers: {'content-type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': 'Failed to check if poem is saved: ${e.toString()}'}),
        headers: {'content-type': 'application/json'},
      );
    }
  }
}
