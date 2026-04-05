import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/zikr_models.dart';

class ZikrService {
  Future<bool> saveZikr(ZikrPhrase phrase, int count, DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/Zikr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'phrase': phrase.key,
          'count': count,
          'date': date.toIso8601String().split('T')[0],
        }),
      );

      if (response.statusCode != 200) {
        print('ZikrService Save Error [${response.statusCode}]: ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('ZikrService Save Exception: $e');
      return false;
    }
  }

  Future<List<ZikrDailySummary>?> getDailySummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/Zikr/daily-summary'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ZikrDailySummary.fromJson(json)).toList();
      } else {
        print('ZikrService Summary Error [${response.statusCode}]: ${response.body}');
      }
      return null;
    } catch (e) {
      print('ZikrService Summary Exception: $e');
      return null;
    }
  }
}
