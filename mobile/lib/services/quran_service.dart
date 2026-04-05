import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah_model.dart';
import '../models/daily_verse_model.dart';
import '../models/daily_verse_model.dart' as verse_model;
import '../config/app_config.dart';

class QuranService {
  Future<DailyVerseModel?> getRandomAyah() async {
    try {
      print('QuranService: getRandomAyah initiated');
      final surahs = await getSurahs();
      if (surahs.isEmpty) {
        print('QuranService: Surah list is empty');
        return null;
      }

      final random = Random();
      final surah = surahs[random.nextInt(surahs.length)];
      final maxAyah = surah.ayahCount > 0 ? surah.ayahCount : 1;
      final ayahId = random.nextInt(maxAyah) + 1;

      final url = '${AppConfig.baseUrl}/quran/open/surahs/${surah.id}/ayahs/$ayahId';
      print('QuranService: Fetching ayah from $url');

      final response = await http
          .get(Uri.parse(url), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('QuranService: Ayah fetch failed with status ${response.statusCode}');
        return null;
      }

      final dynamic data = jsonDecode(response.body);
      print('QuranService: Data received, length: ${response.body.length}');
      
      // AcikKuran API often wraps data in a 'data' field
      final actualData = data['data'] ?? data['Data'] ?? data;
      
      final model = DailyVerseModel.fromJson(actualData, surah.turkishName, surahId: surah.id);
      print('QuranService: Model parsed successfully: ${model.surahName} ${model.ayahNumber}');
      return model;
    } catch (e) {
      print('QuranService getRandomAyah Error: $e');
      return null;
    }
  }

  Future<List<SurahModel>> getSurahs() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/quran/surahs'), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('QuranService getSurahs Error: ${response.statusCode}');
        return [];
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => SurahModel.fromJson(json)).toList();
    } catch (e) {
      print('QuranService getSurahs Error: $e');
      return [];
    }
  }

  Future<List<Map<String, String>>> getReciters() async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/quran/reciters'), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('QuranService getReciters Error: ${response.statusCode}');
        return [];
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => {
        'id': (json['id'] ?? json['Id'] ?? '').toString(),
        'name': (json['name'] ?? json['Name'] ?? '').toString(),
      }).toList();
    } catch (e) {
      print('QuranService getReciters Exception: $e');
      return [];
    }
  }

  Future<List<DailyVerseModel>> getAyahs(int surahId, String surahName) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/quran/open/surahs/$surahId'), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        print('QuranService getAyahs Error: ${response.statusCode}');
        return [];
      }

      final dynamic data = jsonDecode(response.body);
      print('QuranService getAyahs Data received: ${response.body.length} chars');
      
      var rootData = data['data'] ?? data['Data'] ?? data;
      final List<dynamic> versesJson = rootData['verses'] ?? rootData['Verses'] ?? [];
      
      print('QuranService getAyahs: Found ${versesJson.length} verses');
      
      if (versesJson.isEmpty && rootData is List) {
        return rootData.map((json) => DailyVerseModel.fromJson(json, surahName)).toList();
      }

      return versesJson.map((json) => DailyVerseModel.fromJson(json, surahName)).toList();
    } catch (e) {
      print('QuranService getAyahs Exception: $e');
      return [];
    }
  }

  Future<String?> getAyahAudioPath(String reciter, int surahId, int ayahId) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/quran/audio/$reciter/$surahId/$ayahId'), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['audioPath'] ?? data['AudioPath'])?.toString();
      }
    } catch (e) {
      print('QuranService getAyahAudioPath Error: $e');
    }
    return null;
  }

  Future<List<String>> getFullSurahAudioUrls(String reciter, int surahId) async {
    try {
      final response = await http
          .get(Uri.parse('${AppConfig.baseUrl}/quran/audio/$reciter/$surahId/all'), headers: {"X-Platform": "Mobile"})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('QuranService getFullSurahAudioUrls Error: $e');
    }
    return [];
  }
}

