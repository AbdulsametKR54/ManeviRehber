import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';

class LanguageManager extends ChangeNotifier {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  static const String _languageKey = "selected_language";
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString(_languageKey) ?? 'tr';
    _locale = Locale(langCode);
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (_locale.languageCode == langCode) return;
    
    _locale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, langCode);
    notifyListeners();
  }

  Future<void> syncWithProfile() async {
    try {
      final userService = UserService();
      final profile = await userService.getProfile();
      
      if (profile.containsKey('language') || profile.containsKey('Language')) {
        final dbLang = (profile['language'] ?? profile['Language'] ?? 'tr').toString().toLowerCase();
        if (dbLang != _locale.languageCode) {
          await setLanguage(dbLang);
        }
      }
    } catch (e) {
      debugPrint("LanguageManager: Sync error: $e");
    }
  }

  bool get isRTL => _locale.languageCode == 'ar';
}
