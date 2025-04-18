import 'package:flutter/material.dart';
import 'package:metaphora/services/deep_link_service.dart';
import 'package:metaphora/services/offline_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:metaphora/database/database_helper.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize database first
      await DatabaseHelper.instance.initialize();
      
      // Initialize core services
      await Future.wait([
        OfflineService.initialize(),
        DeepLinkService().initialize(),
        SharedPreferences.getInstance(),
      ]);
      
      // Set system UI style
      await _setSystemUIStyle();
      
    } catch (e) {
      debugPrint('Error initializing app: $e');
      // We'll handle this in the UI with our error screens
    }
  }
  
  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('tutorial_completed') ?? false);
  }
  
  static Future<void> _setSystemUIStyle() async {
    // This ensures our aesthetic UI isn't disrupted by system UI
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
