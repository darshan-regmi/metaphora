import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  final String key = "theme_mode";
  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _loadFromPrefs();
  }

  _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  _loadFromPrefs() async {
    await _initPrefs();
    final themeModeIndex = _prefs?.getInt(key) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  }

  _saveToPrefs() async {
    await _initPrefs();
    _prefs?.setInt(key, _themeMode.index);
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _themeMode = value ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs();
    notifyListeners();
  }
  
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveToPrefs();
    notifyListeners();
  }
}
