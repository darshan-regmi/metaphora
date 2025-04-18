import 'package:flutter/material.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/models/comment.dart';
import 'package:metaphora/models/like.dart';
import 'package:metaphora/models/saved_poem.dart';
import 'package:metaphora/repositories/poem_repository.dart';
import 'package:metaphora/repositories/like_repository.dart';
import 'package:metaphora/repositories/comment_repository.dart';
import 'package:metaphora/repositories/saved_poem_repository.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:provider/provider.dart';

class PoemController extends ChangeNotifier {
  final PoemRepository _poemRepository = PoemRepository();
  final LikeRepository _likeRepository = LikeRepository();
  final CommentRepository _commentRepository = CommentRepository();
  final SavedPoemRepository _savedPoemRepository = SavedPoemRepository();
  
  late BuildContext _context;
  
  List<Poem> _poems = [];
  List<Poem> get poems => _poems;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  bool _hasMorePoems = true;
  bool get hasMorePoems => _hasMorePoems;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  int _currentPage = 0;
  static const int _pageSize = 10;

  // Initialize the controller and load initial poems
  Future<void> initialize(BuildContext context) async {
    _context = context;
    await loadInitialPoems();
  }
  
  // Load initial poems for the feed
  Future<void> loadInitialPoems() async {
    _setLoading(true);
    _errorMessage = null;
    _currentPage = 0;
    
    try {
      final poems = await _poemRepository.getAllPoems(limit: _pageSize, offset: 0);
      _poems = poems;
      _hasMorePoems = poems.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load poems: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Load more poems for infinite scrolling
  Future<void> loadMorePoems() async {
    if (_isLoading || !_hasMorePoems) return;
    
    _setLoading(true);
    _errorMessage = null;
    
    try {
      final nextPage = _currentPage + 1;
      final offset = nextPage * _pageSize;
      
      final morePoems = await _poemRepository.getAllPoems(limit: _pageSize, offset: offset);
      
      if (morePoems.isNotEmpty) {
        _poems.addAll(morePoems);
        _currentPage = nextPage;
      }
      
      _hasMorePoems = morePoems.length == _pageSize;
    } catch (e) {
      _errorMessage = 'Failed to load more poems: ${e.toString()}';
      print(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }
  
  // Refresh the poem feed
  Future<void> refreshPoems() async {
    await loadInitialPoems();
  }
  
  // Get a specific poem by ID
  Future<Poem?> getPoemById(int id) async {
    try {
      return await _poemRepository.getPoemById(id);
    } catch (e) {
      _errorMessage = 'Failed to get poem: ${e.toString()}';
      print(_errorMessage);
      return null;
    }
  }
  
  // Get poems by user ID
  Future<List<Poem>> getPoemsByUserId(int userId, {int? limit, int? offset}) async {
    try {
      return await _poemRepository.getPoemsByUserId(userId, limit: limit, offset: offset);
    } catch (e) {
      _errorMessage = 'Failed to get user poems: ${e.toString()}';
      print(_errorMessage);
      return [];
    }
  }
  
  // Get poems by category
  Future<List<Poem>> getPoemsByCategory(String category, {int? limit, int? offset}) async {
    try {
      return await _poemRepository.getPoemsByCategory(category, limit: limit, offset: offset);
    } catch (e) {
      _errorMessage = 'Failed to get poems by category: ${e.toString()}';
      print(_errorMessage);
      return [];
    }
  }
  
  // Search poems
  Future<List<Poem>> searchPoems(String query, {int? limit, int? offset}) async {
    try {
      return await _poemRepository.searchPoems(query, limit: limit, offset: offset);
    } catch (e) {
      _errorMessage = 'Failed to search poems: ${e.toString()}';
      print(_errorMessage);
      return [];
    }
  }
  
  // Create a new poem
  Future<Poem?> createPoem(BuildContext context, String title, String content, {String? category}) async {
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) {
        _errorMessage = 'You must be logged in to create a poem';
        return null;
      }
      
      final newPoem = Poem(
        userId: currentUser.id!,
        title: title,
        content: content,
        category: category,
        createdAt: DateTime.now(),
      );
      
      final createdPoem = await _poemRepository.createPoem(newPoem);
      
      // Add to the beginning of the feed
      _poems.insert(0, createdPoem);
      notifyListeners();
      
      return createdPoem;
    } catch (e) {
      _errorMessage = 'Failed to create poem: ${e.toString()}';
      print(_errorMessage);
      return null;
    }
  }
  
  // Update an existing poem
  Future<Poem?> updatePoem(Poem poem) async {
    try {
      final updatedPoem = await _poemRepository.updatePoem(poem);
      
      // Update in the list
      final index = _poems.indexWhere((p) => p.id == poem.id);
      if (index != -1) {
        _poems[index] = updatedPoem;
        notifyListeners();
      }
      
      return updatedPoem;
    } catch (e) {
      _errorMessage = 'Failed to update poem: ${e.toString()}';
      print(_errorMessage);
      return null;
    }
  }
  
  // Delete a poem
  Future<bool> deletePoem(int id) async {
    try {
      await _poemRepository.deletePoem(id);
      
      // Remove from the list
      _poems.removeWhere((p) => p.id == id);
      notifyListeners();
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete poem: ${e.toString()}';
      print(_errorMessage);
      return false;
    }
  }
  
  // Like a poem
  Future<bool> likePoem(int poemId) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) {
        _errorMessage = 'You must be logged in to like a poem';
        return false;
      }
      
      // Check if already liked
      final alreadyLiked = await _likeRepository.hasUserLikedPoem(currentUser.id!, poemId);
      
      if (alreadyLiked) {
        // Unlike the poem
        await _likeRepository.unlikePoem(currentUser.id!, poemId);
        
        // Update the like count in the UI
        final index = _poems.indexWhere((p) => p.id == poemId);
        if (index != -1) {
          _poems[index] = _poems[index].copyWith(
            likeCount: _poems[index].likeCount - 1,
          );
          notifyListeners();
        }
      } else {
        // Like the poem
        await _likeRepository.createLike(Like(
          userId: currentUser.id!,
          poemId: poemId,
        ));
        
        // Update the like count in the UI
        final index = _poems.indexWhere((p) => p.id == poemId);
        if (index != -1) {
          _poems[index] = _poems[index].copyWith(
            likeCount: _poems[index].likeCount + 1,
          );
          notifyListeners();
        }
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to like poem: ${e.toString()}';
      print(_errorMessage);
      return false;
    }
  }
  
  // Check if user has liked a poem
  Future<bool> hasUserLikedPoem(int poemId) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) return false;
      
      return await _likeRepository.hasUserLikedPoem(currentUser.id!, poemId);
    } catch (e) {
      print('Error checking if user liked poem: ${e.toString()}');
      return false;
    }
  }
  
  // Add a comment to a poem
  Future<Comment?> addComment(int poemId, String content) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) {
        _errorMessage = 'You must be logged in to comment';
        return null;
      }
      
      final comment = Comment(
        userId: currentUser.id!,
        poemId: poemId,
        content: content,
      );
      
      final createdComment = await _commentRepository.createComment(comment);
      
      // Update the comment count in the UI
      final index = _poems.indexWhere((p) => p.id == poemId);
      if (index != -1) {
        _poems[index] = _poems[index].copyWith(
          commentCount: _poems[index].commentCount + 1,
        );
        notifyListeners();
      }
      
      return createdComment;
    } catch (e) {
      _errorMessage = 'Failed to add comment: ${e.toString()}';
      print(_errorMessage);
      return null;
    }
  }
  
  // Get comments for a poem
  Future<List<Comment>> getComments(int poemId, {int? limit, int? offset}) async {
    try {
      return await _commentRepository.getCommentsByPoemId(poemId, limit: limit, offset: offset);
    } catch (e) {
      _errorMessage = 'Failed to get comments: ${e.toString()}';
      print(_errorMessage);
      return [];
    }
  }
  
  // Save a poem
  Future<bool> savePoem(int poemId) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) {
        _errorMessage = 'You must be logged in to save a poem';
        return false;
      }
      
      // Check if already saved
      final alreadySaved = await _savedPoemRepository.hasUserSavedPoem(currentUser.id!, poemId);
      
      if (alreadySaved) {
        // Unsave the poem
        await _savedPoemRepository.unsavePoem(currentUser.id!, poemId);
      } else {
        // Save the poem
        await _savedPoemRepository.savePoem(SavedPoem(
          userId: currentUser.id!,
          poemId: poemId,
        ));
      }
      
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save poem: ${e.toString()}';
      print(_errorMessage);
      return false;
    }
  }
  
  // Check if user has saved a poem
  Future<bool> hasUserSavedPoem(int poemId) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) return false;
      
      return await _savedPoemRepository.hasUserSavedPoem(currentUser.id!, poemId);
    } catch (e) {
      print('Error checking if user saved poem: ${e.toString()}');
      return false;
    }
  }
  
  // Get saved poems for current user
  Future<List<Poem>> getSavedPoems({int? limit, int? offset}) async {
    try {
      final authController = Provider.of<AuthController>(_context, listen: false);
      final currentUser = authController.currentUser;
      
      if (currentUser == null) return [];
      
      final savedPoems = await _savedPoemRepository.getSavedPoemsByUserId(
        currentUser.id!, 
        limit: limit, 
        offset: offset
      );
      
      // Get the actual poems
      List<Poem> poems = [];
      for (var savedPoem in savedPoems) {
        final poem = await _poemRepository.getPoemById(savedPoem.poemId);
        if (poem != null) {
          poems.add(poem);
        }
      }
      
      return poems;
    } catch (e) {
      _errorMessage = 'Failed to get saved poems: ${e.toString()}';
      print(_errorMessage);
      return [];
    }
  }
  
  // Get the next poem in the feed
  Future<Poem?> getNextPoem(int currentPoemId) async {
    try {
      return await _poemRepository.getNextPoem(currentPoemId);
    } catch (e) {
      print('Error getting next poem: ${e.toString()}');
      return null;
    }
  }
  
  // Get the previous poem in the feed
  Future<Poem?> getPreviousPoem(int currentPoemId) async {
    try {
      return await _poemRepository.getPreviousPoem(currentPoemId);
    } catch (e) {
      print('Error getting previous poem: ${e.toString()}');
      return null;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set the context
  void setContext(BuildContext context) {
    _context = context;
  }
}


