import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager extends ChangeNotifier {
  static final ThemeManager _instance = ThemeManager._internal();
  factory ThemeManager() => _instance;
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.light;
  Color _primaryColor = const Color(0xFF1E5F4F);

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool("isDark") ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    final colorVal = prefs.getInt("primaryColor");
    if (colorVal != null) {
      _primaryColor = Color(colorVal);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("isDark", mode == ThemeMode.dark);
    _themeMode = mode;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setPrimaryColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("primaryColor", color.toARGB32());
    _primaryColor = color;
    notifyListeners();
  }
}

