import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:metaphora/models/poem.dart';

class OfflineService {
  static const String _poemBox = 'poems';
  static const String _pendingActionsBox = 'pending_actions';

  // Initialize Hive and open boxes
  static Future<void> initialize() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_poemBox);
    await Hive.openBox<String>(_pendingActionsBox);
  }

  // Cache a poem for offline reading
  Future<void> cachePoem(Poem poem) async {
    final box = Hive.box<String>(_poemBox);
    await box.put(
      poem.id.toString(),
      jsonEncode(poem.toJson()),
    );
  }

  // Get cached poem
  Future<Poem?> getCachedPoem(int id) async {
    final box = Hive.box<String>(_poemBox);
    final poemJson = box.get(id.toString());
    if (poemJson != null) {
      return Poem.fromJson(jsonDecode(poemJson));
    }
    return null;
  }

  // Get all cached poems
  Future<List<Poem>> getAllCachedPoems() async {
    final box = Hive.box<String>(_poemBox);
    return box.values
        .map((json) => Poem.fromJson(jsonDecode(json)))
        .toList();
  }

  // Store pending action for offline sync
  Future<void> storePendingAction({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final box = Hive.box<String>(_pendingActionsBox);
    final action = {
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await box.add(jsonEncode(action));
  }

  // Sync pending actions when online
  Future<void> syncPendingActions() async {
    final box = Hive.box<String>(_pendingActionsBox);
    final actions = box.values
        .map((json) => jsonDecode(json))
        .toList();

    for (final action in actions) {
      try {
        // Process each action based on type
        switch (action['type']) {
          case 'like':
            // Implement like sync
            break;
          case 'comment':
            // Implement comment sync
            break;
          case 'save':
            // Implement save sync
            break;
        }
        // Remove successful action
        await box.delete(action['key']);
      } catch (e) {
        print('Error syncing action: $e');
        // Keep failed actions for retry
      }
    }
  }

  // Clear old cached poems
  Future<void> clearOldCache() async {
    final box = Hive.box<String>(_poemBox);
    final now = DateTime.now();
    final poems = box.values.map((json) => jsonDecode(json)).toList();

    for (final poem in poems) {
      final cachedDate = DateTime.parse(poem['cached_at']);
      if (now.difference(cachedDate).inDays > 7) {
        await box.delete(poem['id'].toString());
      }
    }
  }
}
