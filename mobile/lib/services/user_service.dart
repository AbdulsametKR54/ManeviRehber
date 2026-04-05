import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class UserService {
  static const String baseUrl = "${AppConfig.baseUrl}/users";

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await _getToken();
      if (token == null) return {"error": "Token bulunamadı"};

      final response = await http.get(
        Uri.parse("$baseUrl/me"),
        headers: {
          "Content-Type": "application/json",
          "X-Platform": "Mobile",
          "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 10));

      print("UserService: getProfile status: ${response.statusCode}");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"error": "Profil yüklenemedi", "status": response.statusCode};
      }
    } catch (e) {
      print("UserService: getProfile error: $e");
      return {"error": e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? password,
    String? language,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) return {"error": "Token bulunamadı"};

      final response = await http.put(
        Uri.parse("$baseUrl/me"),
        headers: {
          "Content-Type": "application/json",
          "X-Platform": "Mobile",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          if (name != null) "name": name,
          if (email != null) "email": email,
          if (password != null) "password": password,
          if (language != null) "language": language,
        }),
      ).timeout(const Duration(seconds: 10));

      print("UserService: updateProfile status: ${response.statusCode}");

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {"success": true};
      } else {
        return {"error": "Bilgiler güncellenemedi", "status": response.statusCode};
      }
    } catch (e) {
      print("UserService: updateProfile error: $e");
      return {"error": e.toString()};
    }
  }
}
