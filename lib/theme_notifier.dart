import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('dark_mode') ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', isDarkMode);
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}