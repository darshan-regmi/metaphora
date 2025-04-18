import 'dart:async';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/controllers/client/poem_controller.dart';
import 'package:metaphora/services/offline_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _poemController = PoemController();
  StreamSubscription? _linkSubscription;
  bool _initialized = false;

  // Initialize deep linking
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Handle initial URI if app was opened from a link
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri.toString());
      }

      // Listen for subsequent links
      _linkSubscription = uriLinkStream.listen(
        (Uri? uri) {
          if (uri != null) {
            _handleDeepLink(uri.toString());
          }
        },
        onError: (err) {
          print('Deep link error: $err');
        },
      );

      _initialized = true;
    } on PlatformException {
      print('Failed to initialize deep links');
    }
  }

  // Handle incoming deep link
  Future<void> _handleDeepLink(String link) async {
    // Parse the link
    final uri = Uri.parse(link);
    
    // Handle different deep link patterns
    switch (uri.pathSegments.first) {
      case 'poem':
        if (uri.pathSegments.length > 1) {
          final poemId = int.tryParse(uri.pathSegments[1]);
          if (poemId != null) {
            // Navigate to poem
            await _handlePoemDeepLink(poemId);
          }
        }
        break;
      case 'user':
        if (uri.pathSegments.length > 1) {
          final username = uri.pathSegments[1];
          await _handleUserDeepLink(username);
        }
        break;
      case 'category':
        if (uri.pathSegments.length > 1) {
          final category = uri.pathSegments[1];
          await _handleCategoryDeepLink(category);
        }
        break;
    }
  }

  // Handle poem-specific deep link
  Future<void> _handlePoemDeepLink(int poemId) async {
    // First check offline cache
    final offlineService = OfflineService();
    Poem? poem = await offlineService.getCachedPoem(poemId);
  }

  // Handle user profile deep link
  Future<void> _handleUserDeepLink(String username) async {
    // Navigate to user profile
    // Implementation depends on your navigation setup
  }

  // Handle category deep link
  Future<void> _handleCategoryDeepLink(String category) async {
    // Navigate to category view
    // Implementation depends on your navigation setup
  }

  // Generate sharing link for a poem
  String generatePoemShareLink(int poemId) {
    return 'metaphora://poem/$poemId';
  }

  // Clean up resources
  void dispose() {
    _linkSubscription?.cancel();
  }
}
