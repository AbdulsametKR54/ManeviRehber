import 'package:shared_preferences/shared_preferences.dart';
import '../models/daily_verse_model.dart';

class UserProgressService {
  static const String _keyLastSurahId = 'last_surah_id';
  static const String _keyLastSurahName = 'last_surah_name';
  static const String _keyLastAyahNumber = 'last_ayah_number';

  Future<void> saveLastPosition({
    required int surahId,
    required String surahName,
    required int ayahNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastSurahId, surahId);
    await prefs.setString(_keyLastSurahName, surahName);
    await prefs.setInt(_keyLastAyahNumber, ayahNumber);
    print('UserProgressService: Saved progress - $surahName $ayahNumber');
  }

  Future<DailyVerseModel?> getLocalLastPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final surahId = prefs.getInt(_keyLastSurahId);
    final surahName = prefs.getString(_keyLastSurahName);
    final ayahNumber = prefs.getInt(_keyLastAyahNumber);

    if (surahId == null || surahName == null || ayahNumber == null) {
      return null;
    }

    return DailyVerseModel(
      arabic: '', 
      translation: '',
      surahName: surahName,
      ayahNumber: ayahNumber,
      surahId: surahId,
    );
  }
}
