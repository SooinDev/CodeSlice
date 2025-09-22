import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isChanging = false;
  SharedPreferences? _prefs;

  ThemeMode get themeMode => _themeMode;
  bool get isChanging => _isChanging;

  ThemeNotifier() {
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadTheme();
    } catch (e) {
      debugPrint('Failed to initialize SharedPreferences: $e');
    }
  }

  void _loadTheme() {
    if (_prefs == null) return;

    final isDarkMode = _prefs!.getBool('dark_mode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setTheme(bool isDarkMode) async {
    if (_isChanging) return;

    _isChanging = true;

    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setBool('dark_mode', isDarkMode);
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }

    _isChanging = false;
    notifyListeners();
  }
}