import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/prayer_times_model.dart';
import '../models/daily_table_model.dart';
import '../models/special_day_model.dart';

class PrayerService {
  Future<PrayerTimesModel?> getTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final locationId = prefs.getInt('selected_location_id') ?? 9544;
      
      // Get today's date formatted as YYYY-MM-DD
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/PrayerTime/daily/$locationId/$today'),
        headers: {
          "X-Platform": "Mobile",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      print('PrayerService Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('PrayerService Error Body: ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body);
      print('PrayerService Data Fetched Successfully.');
      return PrayerTimesModel.fromJson(data);
    } catch (e) {
      print('PrayerService Exception: $e');
      return null;
    }
  }

  Future<List<DailyTableModel>?> getMonthlyTimes(int year, int month) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final locationId = prefs.getInt('selected_location_id') ?? 9544;
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/PrayerTime/monthly/$locationId/$year/$month'),
        headers: {
          "X-Platform": "Mobile",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      print('PrayerService Monthly Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('PrayerService Monthly Error: ${response.body}');
        return null;
      }

      final List<dynamic> data = jsonDecode(response.body);
      print('PrayerService Monthly Data Fetched Successfully.');
      return data.map((item) => DailyTableModel.fromJson(item)).toList();
    } catch (e) {
      print('PrayerService Monthly Exception: $e');
      return null;
    }
  }

  Future<List<SpecialDayModel>?> getSpecialDays() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/SpecialDays'),
        headers: {
          "X-Platform": "Mobile",
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      print('PrayerService SpecialDays Status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('PrayerService SpecialDays Error: ${response.body}');
        return null;
      }

      final List<dynamic> data = jsonDecode(response.body);
      print('PrayerService SpecialDays Data Fetched Successfully.');
      return data.map((item) => SpecialDayModel.fromJson(item)).toList();
    } catch (e) {
      print('PrayerService SpecialDays Exception: $e');
      return null;
    }
  }
}
